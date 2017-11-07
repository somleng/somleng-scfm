class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception, :if => :protect_from_forgery?

  private

  def protect_from_forgery?
    true
  end
end
