class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :blueprints ]

  def blueprints
    @user = User.find(params[:user_id])
    authorize @user

    @blueprints = @user.blueprints
      .joins(:collection)
      .where(collection: { type: "Public" })
      .includes(:collection)
      .page(params[:page])
      .order(cached_votes_total: :desc)
  end

  def my_collections
    @type = params[:type] || 'All'
    @collections = current_user.collections

    if @type == 'Public'
      @collections = @collections.where(type: 'Public')
    elsif @type == 'Private'
      @collections = @collections.where(type: 'Private')
    end

    @collections = @collections
      .order(created_at: :desc)
      .page(params[:page])

    authorize current_user
  end
end
