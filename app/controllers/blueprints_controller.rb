class BlueprintsController < ApplicationController
  include BlueprintsFilters

  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    set_filters
    @blueprints = policy_scope(Blueprint)
      .joins(:collection)
      .where(collection: { type: "Public" })
      .includes(:collection)

    @blueprints = filter(@blueprints)

    # Paginate
    @blueprints = @blueprints.page(params[:page])
  end

  def show
    @blueprint = Blueprint.friendly.find(params[:id])
    authorize @blueprint
  end

  def new
    @collection = params[:blueprint] && params[:blueprint][:collection] ?
      current_user.collections.friendly.find(params[:blueprint][:collection]) :
      current_user.collections.where(type: "Public").first

    if !@collection
      flash[:alert] = "You don't seem to have any collection, please create one before adding a blueprint."
      redirect_to collections_users_path
      authorize Blueprint.new
    else
      @blueprint = @collection.blueprints.new
      authorize @blueprint
    end

  end

  def create
    @collection = current_user.collections.find(params[:blueprint][:collection])
    @blueprint = @collection.blueprints.new(blueprint_params)
    @blueprint.tag_list = params[:tag_list]

    authorize @blueprint

    if @blueprint.save
      flash[:notice] = "Blueprint successfully created."
      redirect_to blueprint_path(@blueprint)
    else
      render 'blueprints/new'
    end
  end

  def edit
    @blueprint = Blueprint.friendly.find(params[:id])
    @collection = @blueprint.collection

    authorize @blueprint
  end

  def update
    @collection = current_user.collections.find(params[:blueprint][:collection])
    @blueprint = current_user.blueprints.friendly.find(params[:id])

    @blueprint.collection = @collection
    @blueprint.assign_attributes(blueprint_params)
    @blueprint.tag_list = params[:tag_list]

    authorize @blueprint

    if @blueprint.save
      flash[:notice] = "Blueprint successfully updated."
      redirect_to blueprint_path(@blueprint)
    else
      render 'blueprints/edit'
    end
  end

  def destroy
    @blueprint = current_user.blueprints.friendly.find(params[:id])
    authorize @blueprint
    @blueprint.destroy
    flash[:notice] = "Blueprint successfully deleted."
    redirect_to blueprints_users_path
  end

  def like
    @blueprint = Blueprint.find(params[:id])
    authorize @blueprint

    @blueprint.liked_by current_user
    redirect_to @blueprint
  end

  def unlike
    @blueprint = Blueprint.find(params[:id])
    authorize @blueprint

    @blueprint.unliked_by current_user
    redirect_to @blueprint
  end

  private

  def blueprint_params
    params.require(:blueprint).permit(:title, :description, :encoded_blueprint, :cover_picture, :mod_id, :mod_version, additional_pictures_attributes: {})
  end
end
