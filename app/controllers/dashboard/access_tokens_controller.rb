class Dashboard::AccessTokensController < Dashboard::AdminController
  def index
    @access_tokens = current_account.access_tokens
  end
end
