class UsersController < ApplicationController
  include BlueprintsFilters
  skip_before_action :authenticate_user!, only: [:blueprints]

  def blueprints
    @user = User.find(params[:user_id])
    authorize @user

    @blueprints = @user.blueprints.light_query
      .joins(:collection)
      .where(collection: { type: "Public" })
      .with_associations
      .order(cached_votes_total: :desc)
      .page(params[:page])
  end

  def my_favorites
    set_filters
    @blueprints = filter(current_user.get_voted(Blueprint).light_query.with_associations)
    # Paginate
    @blueprints = @blueprints.page(params[:page])

    authorize current_user
  end

  def my_blueprints
    set_filters
    @blueprints = filter(current_user.blueprints.light_query.with_associations)

    # Paginate
    @blueprints = @blueprints.page(params[:page])

    authorize current_user
  end

  def my_collections
    @type = params[:type] || "All"
    @collections = current_user.collections

    if @type == "Public"
      @collections = @collections.where(type: "Public")
    elsif @type == "Private"
      @collections = @collections.where(type: "Private")
    end

    @collections = @collections
      .left_joins(:blueprints)
      .group("collections.id")
      .select("collections.*, COUNT(blueprints.id) as blueprints_count, COALESCE(SUM(blueprints.cached_votes_total), 0) as total_votes_sum")
      .order(created_at: :desc)
      .page(params[:page])

    authorize current_user
  end
end
