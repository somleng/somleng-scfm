class Dashboard::AccessTokensController < Dashboard::AdminController
  private

  def association_chain
    current_account.access_tokens
  end

  def build_resource_from_params
    @resource = association_chain.build
  end

  def prepare_resource_for_create
    resource.created_by = current_user.account
  end

  def respond_with_created_resource
    respond_with_resource(location: resources_path)
  end

  def resources_path
    dashboard_access_tokens_path
  end
end
