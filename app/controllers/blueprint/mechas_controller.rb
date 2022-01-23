class Blueprint::MechasController < ApplicationController
  include ProfanityChecker

  skip_after_action :verify_authorized, only: [:analyze]

  def new
    @collection = params[:blueprint_mecha] && params[:blueprint_mecha][:collection] ?
                    current_user.collections.friendly.find(params[:blueprint_mecha][:collection]) :
                    current_user.collections.where(type: "Public").first

    if @collection
      @mecha_blueprint = @collection.mecha_blueprints.new
      authorize @mecha_blueprint
    else
      flash[:alert] = "You don't seem to have any collection, please create one before adding a blueprint."
      redirect_to collections_users_path
      authorize Blueprint::Mecha.new
    end
  end

  def create
    mod = @mods.find { |m| m.name == "Dyson Sphere Program" }
    @collection = current_user.collections.find(params[:blueprint_mecha][:collection])
    @mecha_blueprint = @collection.mecha_blueprints.new(mecha_blueprint_params)
    @mecha_blueprint.mod = mod
    @mecha_blueprint.mod_version = mod.version_list.first
    @mecha_blueprint.tag_list = create_tags

    authorize @mecha_blueprint

    if @mecha_blueprint.save
      flash[:notice] = "Mecha blueprint successfully created."
      redirect_to blueprint_path(@mecha_blueprint)
    else
      render "blueprint/mechas/new"
    end
  end

  def edit
    @mecha_blueprint = Blueprint::Mecha.friendly.find(params[:id])
    @collection = @mecha_blueprint.collection

    authorize @mecha_blueprint
  end

  def update
    @collection = current_user.collections.find(params[:blueprint_mecha][:collection])
    @mecha_blueprint = current_user.mecha_blueprints.friendly.find(params[:id])

    @mecha_blueprint.collection = @collection
    @mecha_blueprint.assign_attributes(mecha_blueprint_params)
    @mecha_blueprint.tag_list = create_tags

    authorize @mecha_blueprint

    if @mecha_blueprint.save
      flash[:notice] = "Mecha blueprint successfully updated."
      redirect_to blueprint_path(@mecha_blueprint)
    else
      render "blueprint/mechas/edit"
    end
  end

  def analyze
    if params[:mecha_file]
      data = Parsers::MechaFile.extract_data(params[:mecha_file].tempfile)
      valid = data[:valid]
      if valid
        render json: {
          name: data[:name],
          preview: data[:image_b64],
          valid: valid,
        }
      else
        render json: { error: "Invalid file" }, status: :unprocessable_entity
      end
    else
      render json: { error: "Missing file" }, status: :unprocessable_entity
    end
  end

  private

  def create_tags
    # TODO: Should probably not be here
    # Create tags that don't exist but in the mecha category
    params[:tag_list].split(",").filter do |tag|
      new_tag = tag.titleize
      is_profane = profane?(new_tag)
      ActsAsTaggableOn::Tag.create(name: new_tag, category: "mecha") if !is_profane

      !is_profane
    end
  end

  def mecha_blueprint_params
    params.require(:blueprint_mecha).permit(:title, :description, :blueprint_file, additional_pictures_attributes: {})
  end
end
