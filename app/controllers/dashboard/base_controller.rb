require "application_responder"

class Dashboard::BaseController < ApplicationController
  self.responder = ApplicationResponder
  respond_to :html
  before_action :authenticate_user!

  def current_account
    current_user.account
  end
end
