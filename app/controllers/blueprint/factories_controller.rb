class Blueprint::FactoriesController < ApplicationController
  def new
    if params[:blueprint_factory] && params[:blueprint_factory][:collection]
      @collection = current_user.collections.friendly.find(params[:blueprint_factory][:collection])
    else
      collections = current_user.collections.where(type: "Public", category: "factories")
      @collection = collections.first || current_user.collections.where(type: "Public").first
    end

    if @collection
      @factory_blueprint = @collection.factory_blueprints.new
      authorize @factory_blueprint
    else
      flash[:alert] = "You don't seem to have any collection, please create one before adding a blueprint."
      redirect_to collections_users_path
      authorize Blueprint::Factory.new
    end
  end

  def create
    mod = @mods.find { |m| m.name == "Dyson Sphere Program" }
    @collection = current_user.collections.find(params[:blueprint_factory][:collection])
    @factory_blueprint = @collection.factory_blueprints.new(factory_blueprint_params)
    @factory_blueprint.mod = mod
    @factory_blueprint.mod_version = mod.version_list.first
    @factory_blueprint.tag_list = params[:tag_list]

    authorize @factory_blueprint

    if @factory_blueprint.save
      flash[:notice] = "Factory blueprint successfully created."
      redirect_to blueprint_path(@factory_blueprint)
    else
      render "blueprint/factories/new"
    end
  end

  def edit
    @factory_blueprint = Blueprint::Factory.friendly.find(params[:id])
    @collection = @factory_blueprint.collection

    authorize @factory_blueprint
  end

  def update
    @collection = current_user.collections.find(params[:blueprint_factory][:collection])
    @factory_blueprint = current_user.factory_blueprints.friendly.find(params[:id])

    @factory_blueprint.collection = @collection
    @factory_blueprint.assign_attributes(factory_blueprint_params)
    @factory_blueprint.tag_list = params[:tag_list]

    authorize @factory_blueprint

    if @factory_blueprint.save
      flash[:notice] = "Factory blueprint successfully updated."
      redirect_to blueprint_path(@factory_blueprint)
    else
      render "blueprint/factories/edit"
    end
  end

  private

  def factory_blueprint_params
    params.require(:blueprint_factory).permit(:title, :description, :encoded_blueprint, :cover_picture, additional_pictures_attributes: {})
  end
end
