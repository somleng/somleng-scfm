class Dashboard::AccessTokensController < Dashboard::BaseController
  def index
    @access_tokens = current_account.access_tokens
  end
end
