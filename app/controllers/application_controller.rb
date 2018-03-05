class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception, :if => :protect_against_forgery?

  layout :layout_by_resource

  private

  def layout_by_resource
    if user_signed_in?
      'dashboard'
    else
      'application'
    end
  end
end
