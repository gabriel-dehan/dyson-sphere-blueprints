module BlueprintsFilters
  extend ActiveSupport::Concern

  included do
    def set_filters
      @filters = {
        search: params[:search],
        tags: (params[:tags] || "").split(", "),
        order: params[:order] || "recent",
        mod_id: params[:mod_id].blank? ? 'Any' : params[:mod_id],
        mod_version: params[:mod_version].blank? ? 'Any' : params[:mod_version],
      }
    end

    def filter(blueprints)
      # TODO: At some point when we have hundreds of thousands of blueprints, this will need to be optimized

      if !@filters[:tags].blank?
        blueprints = blueprints.tagged_with(@filters[:tags], :any => true)
      end

      if @filters[:search] && !@filters[:search].blank?
        blueprints = blueprints.search_by_title(@filters[:search])
      end

      if @filters[:mod_id] && @filters[:mod_id] != 'Any'
        blueprints = blueprints.where(mod_id: @filters[:mod_id])
      end

      if @filters[:mod_version] && @filters[:mod_version] != 'Any'
        if @filters[:mod_id]
          mod = Mod.find(@filters[:mod_id])
          compat_list = mod.compatibility_list_for(@filters[:mod_version])
          blueprints = blueprints.where(mod_version: compat_list)
        else
          blueprints = blueprints.where(mod_version: @filters[:mod_version])
        end
      end

      if @filters[:order] === 'recent'
        blueprints = blueprints.reorder(created_at: :desc)
      elsif @filters[:order] === 'popular'
        blueprints = blueprints.reorder(cached_votes_total: :desc)
      end

      blueprints
    end
  end

end