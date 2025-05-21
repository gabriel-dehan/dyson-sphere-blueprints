module BlueprintsFilters
  extend ActiveSupport::Concern

  included do
    def set_filters
      @filters = {
        search: params[:search],
        type: params[:type].presence,
        filtered_for: nil,
        tags: (params[:tags] || "").split(", "),
        author: params[:author],
        order: params[:order] || "recent",
        max_structures: params[:max_structures] || "Any",
        mod_id: params[:mod_id].presence || @mods.first.id,
        mod_version: params[:mod_version].presence || "Any",
        color: params[:color].presence,
        color_similarity: params[:color_similarity].presence,
      }

      if @filters[:mod_id] && @filters[:mod_id] != "Any"
        @filter_mod = @mods.find { |mod| mod.id == @filters[:mod_id].to_i }

        if !@filter_mod
          @filter_mod = @mods.first
          @filters[:mod_id] = @filter_mod.id
        end
      else
        @filter_mod = @mods.first
      end
    end

    def filter(blueprints)
      # TODO: At some point when we have hundreds of thousands of blueprints, this will need to be optimized
      blueprints = blueprints.where(type: @filters[:type].classify) if @filters[:type].present?
      blueprints = blueprints.search_by_title(@filters[:search]) if @filters[:search].present?

      if @filters[:author].present?
        blueprints = blueprints.joins(:user).where("users.username ILIKE ?", "%#{@filters[:author]}%")
      end

      blueprints = blueprints.where(mod_id: @filters[:mod_id]) if @filters[:mod_id].present? && @filters[:mod_id] != "Any"

      if @filters[:mod_version].present? && @filters[:mod_version] != "Any"
        if @filters[:mod_id].present?
          mod = Mod.find(@filters[:mod_id])
          compat_list = mod.compatibility_list_for(@filters[:mod_version])
          blueprints = blueprints.where(mod_version: compat_list)
        else
          blueprints = blueprints.where(mod_version: @filters[:mod_version])
        end
      end

      if @filters[:color].present? && @filters[:color_similarity].present?
        # TODO: Create real scopes and not this horrible thing
        @filters[:filtered_for] = :mechas
        blueprint_ids = colors_by_hsl(@filters[:color], @filters[:color_similarity]).joins(:blueprint_mecha_colors).select("blueprint_mecha_colors.blueprint_id")
        blueprints = blueprints.where(id: blueprint_ids)
      end

      # Mass 5 is infinity so we can return any blueprint
      if @filters[:max_structures].present? && @filters[:max_structures] != "Any" && @filters[:max_structures] != "mass-5"
        # TODO: Create real scopes and not this horrible thing
        @filters[:filtered_for] = :factories
        limit = Engine::Researches::MASS_CONSTRUCTION_LIMITS[@filters[:max_structures]]
        blueprints = blueprints.where("(summary ->> 'total_structures')::int <= ?", limit) if limit
      end

      # OLD: Remove if it works properly now
      # blueprints = blueprints.tagged_with(@filters[:tags]) if @filters[:tags].present?

      # Optimised tag search code
      if @filters[:tags].present?
        blueprints = blueprints.where(
          parse_tags(params[:tags]).map do |tag|
            "EXISTS (
              SELECT 1
              FROM taggings t
              JOIN tags tg ON tg.id = t.tag_id
              WHERE t.taggable_id = blueprints.id
                AND t.taggable_type = 'Blueprint'
                AND t.context = 'tags'
                AND lower(tg.name) = ?
            )"
          end.join(' AND '),
          *parse_tags(params[:tags]).map(&:downcase)
        )
      end

      if @filters[:order] == "recent"
        blueprints = blueprints.reorder(created_at: :desc)
      elsif @filters[:order] == "trending"
        # Get blueprints from the last 30 days and calculate trending score
        trending_query = <<-SQL
          SELECT blueprints.*, 
            (
              -- Recent engagement (last 7 days weighted more heavily)
              (
                COALESCE((SELECT COUNT(*) FROM votes WHERE votes.votable_id = blueprints.id AND votes.created_at >= '#{7.days.ago}'), 0) * 2.0 +
                COALESCE((SELECT COUNT(*) FROM comments WHERE comments.blueprint_id = blueprints.id AND comments.created_at >= '#{7.days.ago}'), 0) * 3.0 +
                blueprints.usage_count * 4.0  -- Using usage_count directly
              ) * 2.0 +  -- Double weight for recent activity
              -- Total engagement
              (blueprints.cached_votes_total * 1.0 + 
               COALESCE((SELECT COUNT(*) FROM comments WHERE comments.blueprint_id = blueprints.id), 0) * 2.0 +
               blueprints.usage_count * 3.0)
            ) * 
            -- Time boost: newer blueprints get a small boost
            (1.0 + (1.0 - (EXTRACT(EPOCH FROM (blueprints.created_at - '#{30.days.ago}'::timestamp)) / 2592000.0)) * 0.5)
            as trending_score
          FROM blueprints
          WHERE blueprints.created_at >= '#{30.days.ago}'
        SQL

        blueprints = Blueprint.from("(#{trending_query}) AS blueprints")
          .includes(:mod, :tags, :tag_taggings, :user)
          .order('trending_score DESC')
      elsif @filters[:order] == "popular"
        blueprints = blueprints.reorder(cached_votes_total: :desc)
      elsif @filters[:order] == "usage"
        blueprints = blueprints.reorder(usage_count: :desc)
      elsif @filters[:order] == "comments"
        comment_counts = Comment.unscoped
          .select('blueprint_id, COUNT(*) as comments_count')
          .group('blueprint_id')
          .to_sql
        
        blueprints = blueprints.joins("LEFT JOIN (#{comment_counts}) AS comment_counts ON comment_counts.blueprint_id = blueprints.id")
          .select('blueprints.*, COALESCE(comment_counts.comments_count, 0) as comments_count')
          .reorder('comments_count DESC')
      end

      blueprints
    end

    def color_tools(searched_color)
      @color_tools ||= Camalian::Color.from_hex(searched_color)
    end

    def color_range(searched_color, color, level)
      (color_tools(searched_color).send(color) - level)..(color_tools(searched_color).send(color) + level)
    end

    def colors_by_rgb(searched_color, similarity)
      level = similarity.to_i * 255 / 100.0
      Color.includes(:blueprint_mecha_colors).where(r: color_range(searched_color, :r, level), g: color_range(searched_color, :g, level), b: color_range(searched_color, :b, level))
    end

    def colors_by_hsl(searched_color, similarity)
      level = similarity.to_i
      Color.includes(:blueprint_mecha_colors).where(h: color_range(searched_color, :h, (similarity.to_i * 30 / 100.0)), s: color_range(searched_color, :s, level), l: color_range(searched_color, :l, level))
    end

    def parse_tags(tags_param)
      return [] if tags_param.blank?

      if tags_param.is_a?(Array)
        tags_param.flat_map { |t| t.split(/\s*,\s*/) }
      else
        tags_param.split(/\s*,\s*/)
      end
    end
  end
end
