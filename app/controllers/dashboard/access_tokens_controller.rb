class Dashboard::AccessTokensController < Dashboard::BaseController
  private

  def association_chain
    current_account.access_tokens
  end

  def prepare_resource_for_create
    resource.created_by = current_user.account
  end

  def permitted_params
    params.require(:access_token).permit(permissions: [])
  end
end
