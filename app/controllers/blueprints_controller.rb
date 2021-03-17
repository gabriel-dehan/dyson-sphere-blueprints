class BlueprintsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @filters = {
      search: params[:search],
      tags: (params[:tags] || "").split(", "),
      order: params[:order] || "recent",
      mod_id: params[:mod_id] || Mod.first.id,
      mod_version: params[:mod_version].blank? ? 'Any' : params[:mod_version]
    }

    # TODO: At some point when we have hundreds of thousands of blueprints, this will not hold
    @blueprints = policy_scope(Blueprint)
      .joins(:collection)
      .where(collection: { type: "Public" })
      .includes(:collection)

      if !@filters[:tags].blank?
        @blueprints = @blueprints.tagged_with(@filters[:tags], :any => true)
      end

      if @filters[:search] && !@filters[:search].blank?
        @blueprints = @blueprints.search_by_title(@filters[:search])
      end

      if @filters[:mod_version] && @filters[:mod_version] != 'Any'
        @blueprints = @blueprints.where(mod_version: @filters[:mod_version])
      end

      if @filters[:mod_id]
        @blueprints = @blueprints.where(mod_id: @filters[:mod_id])
      end

      if @filters[:order] === 'recent'
        @blueprints = @blueprints.reorder(created_at: :desc)
      elsif @filters[:order] === 'popular'
        @blueprints = @blueprints.reorder(cached_votes_total: :desc)
      end

      # Paginate
      @blueprints = @blueprints.page(params[:page])
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
    params.require(:blueprint).permit(:title, :description, :encoded_blueprint, :cover, :mod_id, :mod_version, pictures: [])
  end

end
