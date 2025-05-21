class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]
  before_action :set_blueprint
  before_action :set_comment, only: [:destroy]
  before_action :authorize_user!, only: [:destroy]
  after_action :verify_authorized, except: :index

  def create
    @comment = @blueprint.comments.build(comment_params)
    @comment.user = current_user
    authorize @comment

    if @comment.save
      respond_to do |format|
        format.html { redirect_to blueprint_path(@blueprint), notice: 'Comment was successfully added.' }
        format.turbo_stream
      end
    else
      redirect_to blueprint_path(@blueprint), alert: 'Failed to add comment.'
    end
  end

  def destroy
    authorize @comment
    @comment.update(deleted_at: Time.current)
    respond_to do |format|
      format.html { redirect_to blueprint_path(@blueprint), notice: 'Comment was successfully deleted.' }
      format.turbo_stream
    end
  end

  private

  def set_blueprint
    if params[:factory_id]
      @blueprint = Blueprint::Factory.friendly.find(params[:factory_id])
    elsif params[:dyson_sphere_id]
      @blueprint = Blueprint::DysonSphere.friendly.find(params[:dyson_sphere_id])
    elsif params[:mecha_id]
      @blueprint = Blueprint::Mecha.friendly.find(params[:mecha_id])
    else
      @blueprint = Blueprint.friendly.find(params[:blueprint_id])
    end
  end

  def set_comment
    @comment = @blueprint.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end

  def authorize_user!
    unless @comment.user == current_user
      redirect_to blueprint_path(@blueprint), alert: 'You are not authorized to perform this action.'
    end
  end
end 