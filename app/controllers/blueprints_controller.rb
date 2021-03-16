class BlueprintsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @blueprints = policy_scope(Blueprint)
      .joins(:collection)
      .where(collection: { type: "Public" })
      .includes(:collection)
  end

  def show
    @blueprint = Blueprint.friendly.find(params[:id])
    authorize @blueprint
  end

  def new
    @collection = params[:collection] ?
      current_user.collections.friendly.find(params[:collection]) :
      current_user.collections.where(type: "Private").first

    @blueprint = @collection.blueprints.new

    authorize @blueprint
  end

  def create
    @collection = current_user.collections.find(params[:blueprint][:collection])
    @blueprint = @collection.blueprints.new(blueprint_params)
    @blueprint.tag_list = params[:tag_list]

    authorize @blueprint

    if @blueprint.save
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
      redirect_to blueprint_path(@blueprint)
    else
      render 'blueprints/edit'
    end
  end

  private

  def blueprint_params
    params.require(:blueprint).permit(:title, :description, :encoded_blueprint, :cover, pictures: [], mod_version: )
  end

end
