class Api::AccountsController < Api::FilteredController
  private

  def find_resources_association_chain
    association_chain
  end

  def association_chain
    Account.all
  end

  def filter_class
    Filter::Resource::Account
  end

  def permitted_params
    params.permit(:metadata_merge_mode, :metadata => {})
  end

  def resource_location
    api_account_path(resource)
  end
end
