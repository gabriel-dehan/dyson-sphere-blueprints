class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @filters = {
      search: nil,
      tags: [],
      order: 'recent',
      mod_id: Mod.first.id,
      mod_version: 'Any'
    }

    @blueprints = policy_scope(Blueprint)
      .joins(:collection)
      .where(collection: { type: "Public" })
      .includes(:collection)
      .where(mod_id: @filters[:mod_id])
      .order(created_at: :desc)
      .page(params[:page])
  end
end
