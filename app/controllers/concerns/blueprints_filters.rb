module BlueprintsFilters
  extend ActiveSupport::Concern

  included do
    def set_filters
      @filters = {
        search: params[:search],
        type: params[:type].presence,
        tags: (params[:tags] || "").split(", "),
        author: params[:author],
        order: params[:order] || "recent",
        max_structures: params[:max_structures] || "Any",
        mod_id: params[:mod_id].presence || @mods.first.id,
        mod_version: params[:mod_version].presence || "Any",
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
      blueprints = blueprints.where(type: params[:type].classify) if @filters[:type].present?
      blueprints = blueprints.tagged_with(@filters[:tags], any: true) if @filters[:tags].present?
      blueprints = blueprints.search_by_title(@filters[:search]) if @filters[:search].present?
      blueprints = blueprints.references(:user).where("users.username ILIKE ?", "%#{@filters[:author]}%") if @filters[:author].present?
      blueprints = blueprints.where(mod_id: @filters[:mod_id]) if @filters[:mod_id] && @filters[:mod_id] != "Any"

      if @filters[:mod_version] && @filters[:mod_version] != "Any"
        if @filters[:mod_id]
          mod = Mod.find(@filters[:mod_id])
          compat_list = mod.compatibility_list_for(@filters[:mod_version])
          blueprints = blueprints.where(mod_version: compat_list)
        else
          blueprints = blueprints.where(mod_version: @filters[:mod_version])
        end
      end

      # Mass 5 is infinity so we can return any blueprint
      if @filters[:max_structures] && @filters[:max_structures] != "Any" && @filters[:max_structures] != "mass-5"
        limit = Engine::Researches::MASS_CONSTRUCTION_LIMITS[@filters[:max_structures]]
        blueprints = blueprints.where("(summary ->> 'total_structures')::int <= ?", limit) if limit
      end

      if @filters[:order] == "recent"
        blueprints = blueprints.reorder(created_at: :desc)
      elsif @filters[:order] == "popular"
        blueprints = blueprints.reorder(cached_votes_total: :desc)
      end

      blueprints
    end
  end
end
