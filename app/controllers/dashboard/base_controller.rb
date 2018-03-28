class Dashboard::BaseController < ApplicationController
  before_action :authenticate_user!

  def current_account
    current_user.account
  end

  private

  def authorize_admin!
    deny_access! unless current_user.is_admin?
  end

  def deny_access!
    redirect_to dashboard_root_path, alert: "We're sorry, but you do not have permission to view this page."
  end
end
