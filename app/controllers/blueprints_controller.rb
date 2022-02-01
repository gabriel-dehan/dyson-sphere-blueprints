class BlueprintsController < ApplicationController
  include BlueprintsFilters

  skip_before_action :authenticate_user!, only: [:index, :show]

  def show
    @blueprint = Blueprint.friendly.find(params[:id])
    authorize @blueprint

    respond_to do |format|
      format.html do
        render "blueprint/#{@blueprint.type.underscore.pluralize}/show"
      end
      format.text { render plain: @blueprint.encoded_blueprint }
    end
  end

  def index
    set_filters
    @blueprints = policy_scope(Blueprint)
      .where(collection: { type: "Public" })
      .includes(:collection, collection: :user)

    @blueprints = filter(@blueprints)

    # Paginate
    @blueprints = @blueprints.page(params[:page])
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
end
