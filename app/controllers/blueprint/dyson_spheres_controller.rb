class Blueprint::DysonSpheresController < ApplicationController
  include ProfanityChecker

  def new
    @collection = params[:blueprint_dyson_sphere] && params[:blueprint_dyson_sphere][:collection] ?
                    current_user.collections.friendly.find(params[:blueprint_dyson_sphere][:collection]) :
                    current_user.collections.where(type: "Public").first

    if @collection
      @dyson_sphere_blueprint = @collection.dyson_sphere_blueprints.new
      authorize @dyson_sphere_blueprint
    else
      flash[:alert] = "You don't seem to have any collection, please create one before adding a blueprint."
      redirect_to collections_users_path
      authorize Blueprint::DysonSphere.new
    end
  end

  def create
    mod = @mods.find { |m| m.name == "Dyson Sphere Program" }
    @collection = current_user.collections.find(params[:blueprint_dyson_sphere][:collection])
    @dyson_sphere_blueprint = @collection.dyson_sphere_blueprints.new(dyson_sphere_blueprint_params)
    @dyson_sphere_blueprint.mod = mod
    @dyson_sphere_blueprint.mod_version = mod.version_list.first
    @dyson_sphere_blueprint.tag_list = create_tags

    authorize @dyson_sphere_blueprint

    if @dyson_sphere_blueprint.save
      flash[:notice] = "Dyson Sphere blueprint successfully created."
      redirect_to blueprint_path(@dyson_sphere_blueprint)
    else
      render "blueprint/dyson_spheres/new"
    end
  end

  def edit
    @dyson_sphere_blueprint = Blueprint::DysonSphere.friendly.find(params[:id])
    @collection = @dyson_sphere_blueprint.collection

    authorize @dyson_sphere_blueprint
  end

  def update
    @collection = current_user.collections.find(params[:blueprint_dyson_sphere][:collection])
    @dyson_sphere_blueprint = current_user.dyson_sphere_blueprints.friendly.find(params[:id])

    @dyson_sphere_blueprint.collection = @collection
    @dyson_sphere_blueprint.assign_attributes(dyson_sphere_blueprint_params)
    @dyson_sphere_blueprint.tag_list = create_tags

    authorize @dyson_sphere_blueprint

    if @dyson_sphere_blueprint.save
      flash[:notice] = "Dyson Sphere blueprint successfully updated."
      redirect_to blueprint_path(@dyson_sphere_blueprint)
    else
      render "blueprint/dyson_spheres/edit"
    end
  end

  private

  def create_tags
    # TODO: Should probably not be here
    # Create tags that don't exist but in the dyson_sphere category
    params[:tag_list].split(",").filter do |tag|
      new_tag = tag.titleize
      is_profane = profane?(new_tag)
      ActsAsTaggableOn::Tag.create(name: new_tag, category: "dyson_sphere") if !is_profane

      !is_profane
    end
  end

  def dyson_sphere_blueprint_params
    params.require(:blueprint_dyson_sphere).permit(:title, :description, :encoded_blueprint, :cover_picture, additional_pictures_attributes: {})
  end
end
