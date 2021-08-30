class UsersController < ApplicationController
  include BlueprintsFilters
  skip_before_action :authenticate_user!, only: [:blueprints]

  def blueprints
    @user = User.find(params[:user_id])
    authorize @user

    @blueprints = @user.blueprints
      .joins(:collection)
      .where(collection: { type: "Public" })
      .includes(:collection, collection: :user)
      .order(cached_votes_total: :desc)
      .page(params[:page])
  end

  def my_favorites
    set_filters
    @blueprints = filter(current_user.get_voted(Blueprint))
    # Paginate
    @blueprints = @blueprints.page(params[:page])

    authorize current_user
  end

  def my_blueprints
    set_filters
    @blueprints = filter(current_user.blueprints)

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
      .order(created_at: :desc)
      .page(params[:page])

    authorize current_user
  end
end
