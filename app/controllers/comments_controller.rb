class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]
  before_action :set_blueprint
  before_action :set_comment, only: [:destroy]
  before_action :authorize_user!, only: [:destroy]

  def create
    @comment = @blueprint.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      respond_to do |format|
        format.html { redirect_to @blueprint, notice: 'Comment was successfully added.' }
        format.turbo_stream
      end
    else
      redirect_to @blueprint, alert: 'Failed to add comment.'
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to @blueprint, notice: 'Comment was successfully deleted.' }
      format.turbo_stream
    end
  end

  private

  def set_blueprint
    @blueprint = Blueprint.friendly.find(params[:blueprint_id])
  end

  def set_comment
    @comment = @blueprint.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def authorize_user!
    unless @comment.user == current_user
      redirect_to @blueprint, alert: 'You are not authorized to perform this action.'
    end
  end
end 