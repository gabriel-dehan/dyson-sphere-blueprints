class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :help ]

  def home
    @filters = {
      search: nil,
      tags: [],
      order: 'recent',
      mod_id: 'Any',
      mod_version: 'Any'
    }

    @blueprints = policy_scope(Blueprint)
      .joins(:collection)
      .where(collection: { type: "Public" })
      .includes(:collection)
      .order(created_at: :desc)
      .page(params[:page])
  end

  def help
  end
end
