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
        recipe: parse_recipe_filters(params[:recipe]),
        game_version_id: params[:game_version_id].presence || @game_versions.first.id,
        game_version_string: params[:game_version_string].presence || "Any",
        color: params[:color].presence,
        color_similarity: params[:color_similarity].presence,
      }

      if @filters[:game_version_id] && @filters[:game_version_id] != "Any"
        @filter_game_version = @game_versions.find { |gv| gv.id == @filters[:game_version_id].to_i }

        if !@filter_game_version
          @filter_game_version = @game_versions.first
          @filters[:game_version_id] = @filter_game_version.id
        end
      else
        @filter_game_version = @game_versions.first
      end
    end

    def filter(blueprints)
      # TODO: At some point when we have hundreds of thousands of blueprints, this will need to be optimized
      blueprints = blueprints.where(type: @filters[:type].classify) if @filters[:type].present?
      blueprints = blueprints.search_by_title(@filters[:search]) if @filters[:search].present?

      blueprints = blueprints.joins(:user).where("users.username ILIKE ?", "%#{@filters[:author]}%") if @filters[:author].present?

      blueprints = blueprints.where(game_version_id: @filters[:game_version_id]) if @filters[:game_version_id].present? && @filters[:game_version_id] != "Any"

      if @filters[:game_version_string].present? && @filters[:game_version_string] != "Any"
        if @filters[:game_version_id].present?
          game_version = GameVersion.find(@filters[:game_version_id])
          compat_list = game_version.compatibility_list_for(@filters[:game_version_string])
          blueprints = blueprints.where(game_version_string: compat_list)
        else
          blueprints = blueprints.where(game_version_string: @filters[:game_version_string])
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

      # Optimised tag search code
      if @filters[:tags].present?
        blueprints = blueprints.where(
          parse_tags(params[:tags]).map do |_tag|
            "EXISTS (
              SELECT 1
              FROM taggings t
              JOIN tags tg ON tg.id = t.tag_id
              WHERE t.taggable_id = blueprints.id
                AND t.taggable_type = 'Blueprint'
                AND t.context = 'tags'
                AND lower(tg.name) = ?
            )"
          end.join(" AND "),
          *parse_tags(params[:tags]).map(&:downcase)
        )
      end

      if @filters[:recipe].present?
        @filters[:filtered_for] = :factories
        recipe_ids = @filters[:recipe].map { |recipe| recipe.to_i }.reject(&:zero?)
        blueprints = blueprints.where("recipe_ids @> ARRAY[?]::int[]", recipe_ids) if recipe_ids.any?
      end

      if @filters[:order] == "recent"
        blueprints = blueprints.reorder(created_at: :desc)
      elsif @filters[:order] == "popular"
        blueprints = blueprints.reorder(cached_votes_total: :desc)
      elsif @filters[:order] == "usage"
        blueprints = blueprints.reorder(usage_count: :desc)
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
      Color.where(r: color_range(searched_color, :r, level), g: color_range(searched_color, :g, level), b: color_range(searched_color, :b, level))
    end

    def colors_by_hsl(searched_color, similarity)
      level = similarity.to_i
      Color.where(h: color_range(searched_color, :h, (similarity.to_i * 30 / 100.0)), s: color_range(searched_color, :s, level), l: color_range(searched_color, :l, level))
    end

    def parse_tags(tags_param)
      return [] if tags_param.blank?

      if tags_param.is_a?(Array)
        tags_param.flat_map { |t| t.split(/\s*,\s*/) }
      else
        tags_param.split(/\s*,\s*/)
      end
    end

    def parse_recipe_filters(recipe_param)
      return [] if recipe_param.blank?
      return recipe_param if recipe_param.is_a?(Array)

      recipe_param.to_s.split(/\s*,\s*/)
    end
  end
end
