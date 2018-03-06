class Dashboard::BaseController < ApplicationController
  before_action :authenticate_user!

  def current_account
    current_user.account
  end
end
