class Dashboard::AccessTokensController < Dashboard::BaseController
  private

  def association_chain
    current_account.access_tokens
  end
end
