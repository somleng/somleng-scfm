class Dashboard::AccessTokensController < Dashboard::BaseController
  def index
    @access_tokens = current_account.access_tokens.page(params[:page]).per(10)
  end
end
