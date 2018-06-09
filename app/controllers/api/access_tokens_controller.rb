class Api::AccessTokensController < Api::FilteredController
  private

  def find_resources_association_chain
    association_chain
  end

  def association_chain
    specified_or_current_account.access_tokens.all
  end

  def filter_class
    Filter::Resource::AccessToken
  end

  def permitted_params
    params.permit(:metadata_merge_mode, permissions: [], metadata: {})
  end

  def setup_resource
    resource.created_by = current_account
  end

  def before_destroy_resource
    resource.destroyer = current_account
  end

  def resource_location
    api_access_token_path(resource)
  end
end
