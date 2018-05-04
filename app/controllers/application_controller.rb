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
end
