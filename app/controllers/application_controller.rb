class ApplicationController < ActionController::Base
  respond_to :html

  protect_from_forgery with: :exception
end
