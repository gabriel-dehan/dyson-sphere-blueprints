class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit::Authorization
  include HttpAcceptLanguage::AutoLocale
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_game_versions

  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  def user_not_authorized
    flash[:alert] = t("flash.unauthorized")
    redirect_back(fallback_location: root_path)
  end

  private

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    # Priority 1: URL parameter
    return params[:locale] if valid_locale?(params[:locale])

    # Priority 2: User preference (if logged in)
    if user_signed_in? && current_user.preferred_locale.present?
      return current_user.preferred_locale if valid_locale?(current_user.preferred_locale)
    end

    # Priority 3: Cookie (for non-logged in users)
    return cookies[:locale] if valid_locale?(cookies[:locale])

    # Priority 4: Browser Accept-Language header
    http_accept_language.compatible_language_from(I18n.available_locales)
  end

  def valid_locale?(locale)
    locale.present? && I18n.available_locales.map(&:to_s).include?(locale.to_s)
  end

  def default_url_options
    # Only include locale in URL if it's not the default
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
  end

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
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:username, :email, :password, :current_password, :preferred_locale) }
  end
end
