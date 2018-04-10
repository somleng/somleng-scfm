class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception, :if => :protect_against_forgery?

  layout :layout_by_resource

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: [:roles])
  end

  private

  def layout_by_resource
    if user_signed_in?
      'dashboard'
    else
      'application'
    end
  end

  def authorize_admin!
    deny_access! unless current_user.is_admin?
  end

  def deny_access!
    redirect_to dashboard_root_path, alert: "We're sorry, but you do not have permission to view this page."
  end
end
