class BlueprintsController < ApplicationController
  include BlueprintsFilters

  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_cache_headers, only: [:index, :show]

  def show
    @blueprint = Blueprint.friendly.find(params[:id])
    authorize @blueprint

    if stale?(etag: [@blueprint, current_user], last_modified: @blueprint.updated_at, public: true)
      respond_to do |format|
        format.html do
          @blueprint = Blueprint.includes(comments: { user: {}, replies: { user: {} } }).find(@blueprint.id)
          render "blueprint/#{@blueprint.type.underscore.pluralize}/show"
        end
        format.text { render plain: @blueprint.encoded_blueprint }
      end
    end
  end

  def index
    set_filters
    general_scope = policy_scope(Blueprint.light_query)
      .joins(:collection)
      .where(collection: { type: "Public" })

    # Fetch the latest updated_at timestamp for the relevant records
    last_modified = general_scope.maximum(:updated_at)

    # Generate an ETag based on the general_scope and current_user
    if stale?(etag: [general_scope, current_user], last_modified: last_modified, public: true)
      # Apply filters and paginate only if the request is not cached
      @blueprints = filter(general_scope.includes(:collection, collection: :user))

      @blueprints = @blueprints.page(params[:page])
      @blueprints.load
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
    redirect_to blueprint_path(@blueprint)
  end

  def unlike
    @blueprint = Blueprint.find(params[:id])
    authorize @blueprint

    @blueprint.unliked_by current_user
    redirect_to blueprint_path(@blueprint)
  end

  def track
    @blueprint_usage_metric = BlueprintUsageMetric.find_or_initialize_by(blueprint_id: params[:id], user_id: current_user.id)

    authorize @blueprint_usage_metric

    @blueprint_usage_metric.increment(:count)

    if @blueprint_usage_metric.save
      render json: true, status: :ok
    else
      render json: { errors: @blueprint_usage_metric.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def code
    @blueprint = Blueprint.find(params[:id])
    authorize @blueprint

    render plain: @blueprint.encoded_blueprint
  end
end
