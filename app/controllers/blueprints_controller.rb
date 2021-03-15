class BlueprintsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    # TODO: Handle privates
  end

  def show
    # TODO: Handle privates
    @blueprint = current_user.blueprints.friendly.find(params[:id])
  end

  def new
    @collection = params[:collection] ?
      current_user.collections.friendly.find(params[:collection]) :
      current_user.collections.where(type: "Private").first

    @blueprint = @collection.blueprints.new
  end

  def create
    @collection = current_user.collections.find(params[:blueprint][:collection])
    @blueprint = @collection.blueprints.new(blueprint_params)
    @blueprint.tag_list = params[:tag_list]
    if @blueprint.save
      redirect_to blueprint_path(@blueprint)
    else
      render 'blueprints/new'
    end
  end

  def edit
  end

  private

  def blueprint_params
    params.require(:blueprint).permit(:title, :description, :encoded_blueprint, :cover, pictures: [])
  end

end
