class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit::Authorization
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_game_versions

  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def set_game_versions
    @game_versions = GameVersion.all.order(created_at: :desc).to_a
  end

  protected

  def set_cache_headers
    expires_in 1.hour, public: true
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:username, :email, :password) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:username, :email, :password, :current_password) }
  end

  # OLD VERSION OF CACHING NOT USING ETAGS, KEPT FOR REFERENCE

  # # Check if the timestamp, resource or collection has been modified since the last request
  # # Returns true if the resource has not been modified and the request should stop with a 304
  # # Return false if the resource has been modified and the request should continue
  # def use_last_modified_cache(resource_collection_or_time)
  #   # Set cache control headers
  #   expires_in 1.hour, public: true

  #   last_modified = determine_last_modified(resource_collection_or_time)

  #   # Check for a valid last_modified date
  #   return false unless last_modified

  #   headers["Last-Modified"] = last_modified.httpdate

  #   if client_has_fresh_copy?(last_modified)
  #     head :not_modified
  #     return true
  #   end

  #   false
  # end

  # private
  # def determine_last_modified(resource_collection_or_time)
  #   if resource_collection_or_time.is_a?(Time)
  #     resource_collection_or_time
  #   elsif resource_collection_or_time.respond_to?(:maximum)
  #     resource_collection_or_time.maximum(:updated_at)
  #   elsif resource_collection_or_time.respond_to?(:updated_at)
  #     resource_collection_or_time.updated_at
  #   end
  # end

  # def client_has_fresh_copy?(last_modified)
  #   if_modified_since = request.headers['If-Modified-Since']
  #   if_modified_since.present? && Time.httpdate(if_modified_since) >= last_modified
  # end
end
