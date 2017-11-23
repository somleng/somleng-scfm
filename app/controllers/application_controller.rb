class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception, :if => :protect_from_forgery?
end
