class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :help, :support, :wall_of_fame]
  before_action :set_cache_headers, only: [:home]

  def home
    @filters = {
      search: nil,
      tags: [],
      author: nil,
      order: "recent",
      max_structures: "Any",
      game_version_id: @game_versions.first.id,
      game_version_string: "Any",
    }

    @filter_game_version = @game_versions.first

    # Define the general scope
    general_scope = policy_scope(Blueprint.light_query)
      .joins(:collection)
      .where(collection: { type: "Public" })
      .where(game_version_id: @filters[:game_version_id])

    # Fetch the latest updated_at timestamp based on the general scope
    last_modified = general_scope.maximum(:updated_at)

    # Use the general scope and current_user to check if the response would be stale
    if stale?(etag: [general_scope, current_user], last_modified: last_modified, public: true)
      # Apply further criteria and fetch the actual records only if necessary
      @blueprints = general_scope
        .with_associations
        .order(created_at: :desc)
        .page(params[:page])
    end
  end

  def help
  end

  def support
  end

  def wall_of_fame
  end
end
