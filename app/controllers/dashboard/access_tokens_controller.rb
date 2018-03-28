class Dashboard::AccessTokensController < Dashboard::BaseController
  before_action :authorize_admin!

  def index
    @access_tokens = current_account.access_tokens
  end
end
