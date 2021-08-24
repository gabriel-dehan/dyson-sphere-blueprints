class CollectionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @collections = policy_scope(Collection)
      .where(type: "Public")
      .joins(:blueprints)
      .where.not(blueprints: { id: nil })
      .where(blueprints: { mod_id: @mods.first.id }) # TODO: Remove when Multibuild is removed
      .group("collections.id")
      .order("sum(blueprints.cached_votes_total) DESC")
      .page(params[:page])
  end

  def show
    @collection = Collection.friendly.find(params[:id])
    @blueprints = @collection
      .blueprints
      .where(mod_id: @mods.first.id) # TODO: Remove when Multibuild is removed
      .order(cached_votes_total: :desc)
      .page(params[:page])

    authorize @collection
  end

  def new
    @collection = current_user.collections.new
    authorize @collection
  end

  def create
    @collection = current_user.collections.new(collection_params)
    authorize @collection

    if @collection.save
      flash[:notice] = "Collection successfully created."
      redirect_to collection_path(@collection)
    else
      render "collection/new"
    end
  end

  def edit
    @collection = current_user.collections.friendly.find(params[:id])

    authorize @collection
  end

  def update
    @collection = current_user.collections.friendly.find(params[:id])
    @collection.assign_attributes(collection_params)
    authorize @collection

    if @collection.save
      flash[:notice] = "Collection successfully updated."
      redirect_to collection_path(@collection)
    else
      render "collection/edit"
    end
  end

  def destroy
    @collection = current_user.collections.friendly.find(params[:id])
    authorize @collection
    @collection.destroy
    flash[:notice] = "Collection successfully deleted."
    redirect_to collections_users_path
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :type)
  end
end
