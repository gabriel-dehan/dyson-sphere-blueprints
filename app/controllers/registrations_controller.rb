class RegistrationsController < Devise::RegistrationsController
  protected

  def update_resource(resource, params)
    if resource.provider.blank?
      super
    else
      resource.update_without_password(params)
    end
  end
end
