class TagsController < ApplicationController
  include ProfanityChecker

  skip_after_action :verify_policy_scoped, only: [:index]
  skip_after_action :verify_authorized, only: [:profanity_check]

  def index
    respond_to do |format|
      format.json do
        tags = ActsAsTaggableOn::Tag.where(category: params[:category]).pluck(:name)
        render json: tags
      end
    end
  end

  # def create
  #   new_tag = params[:tag].presence
  #   category = params[:category].presence

  #   if new_tag
  #     valid = PROFANE_DICT.exclude?(new_tag.downcase) && !ProfanityFilter.new.profane?(new_tag)
  #   else
  #     valid = false
  #   end

  #   if valid
  #     ActsAsTaggableOn::Tag.create(name: new_tag, category: category)
  #   end

  #   respond_to do |format|
  #     format.json do
  #       render json: valid
  #     end
  #   end
  # end

  def profanity_check
    new_tag = params[:tag] || "";

    respond_to do |format|
      format.json do
        render json: profane?(new_tag)
      end
    end
  end
end
