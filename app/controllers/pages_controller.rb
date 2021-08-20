class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :help]

  def home
    @filters = {
      search: nil,
      tags: [],
      author: nil,
      order: "recent",
      max_structures: "Any",
      mod_id: @mods.first.id,
      mod_version: "Any",
    }

    @filter_mod = @mods.first

    @blueprints = policy_scope(Blueprint)
      .joins(:collection)
      .where(collection: { type: "Public" })
      .where(mod_id: @filters[:mod_id]) # TODO: Probably remove all other mods than basegame
      .includes(:collection)
      .order(created_at: :desc)
      .page(params[:page])
  end

  def help
  end
end
