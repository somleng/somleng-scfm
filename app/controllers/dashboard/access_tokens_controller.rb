class Dashboard::AccessTokensController < Dashboard::AdminController
  private

  def association_chain
    current_account.access_tokens
  end

  def prepare_resource_for_create
    resource.created_by = current_user.account
  end

  def resources_path
    dashboard_access_tokens_path
  end

  def permitted_params
    params.require(:access_token).permit(permissions: [])
  end
end
