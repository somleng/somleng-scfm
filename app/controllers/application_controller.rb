class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception, :if => :protect_against_forgery?
end
