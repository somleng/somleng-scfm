class Api::AuthenticatedController < Api::BaseController
  before_action :api_authenticate!

  private

  def api_authenticate!
    if api_authenticate?
      authenticate_or_request_with_http_basic do |user, password|
        ActiveSupport::SecurityUtils.variable_size_secure_compare(user, http_basic_auth_user) && (!http_basic_auth_password || ActiveSupport::SecurityUtils.variable_size_secure_compare(password, http_basic_auth_password))
      end
    end
  end

  def api_authenticate?
    !!http_basic_auth_user
  end

  def http_basic_auth_user
    ENV["HTTP_BASIC_AUTH_USER"]
  end

  def http_basic_auth_password
    ENV["HTTP_BASIC_AUTH_PASSWORD"]
  end
end
