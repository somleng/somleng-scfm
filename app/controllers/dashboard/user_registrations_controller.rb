class Dashboard::UserRegistrationsController < Devise::RegistrationsController
  protected

  def after_update_path_for(_resource)
    dashboard_root_path
  end
end
