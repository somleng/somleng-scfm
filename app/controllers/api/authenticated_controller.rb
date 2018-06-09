class Api::AuthenticatedController < Api::BaseController
  before_action :doorkeeper_authorize!
  before_action :authorize_access_token_for_read!, only: %i[index show]
  before_action :authorize_access_token_for_write!, only: %i[create update destroy]

  private

  def current_account
    @current_account ||= Account.find(doorkeeper_token&.resource_owner_id)
  end

  def authorize_super_admin!
    deny_access! unless current_account.super_admin?
  end

  def deny_access!
    head(:unauthorized)
  end

  def specified_or_current_account
    current_account.super_admin? && params[:account_id] && Account.find(params[:account_id]) || current_account
  end

  def authorize_access_token_for_read!
    authorize_access_token!(*access_token_read_permissions)
  end

  def access_token_read_permissions
    [:"#{controller_name}_read"]
  end

  def authorize_access_token_for_write!
    authorize_access_token!(*access_token_write_permissions)
  end

  def access_token_write_permissions
    [:"#{controller_name}_write"]
  end

  def authorize_access_token!(*permissions)
    deny_access! unless access_token.permissions?(*permissions)
  end

  def access_token
    doorkeeper_token.becomes(AccessToken)
  end
end
