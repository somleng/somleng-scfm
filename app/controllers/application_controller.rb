class ApplicationController < ActionController::Base
  respond_to :html

  protect_from_forgery with: :exception
  layout :layout_by_resource

  private

  def layout_by_resource
    if user_signed_in?
      "dashboard"
    else
      "application"
    end
  end

  protected

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || dashboard_root_path
  end
end
