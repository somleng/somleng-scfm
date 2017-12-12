class Api::UsersController < Api::FilteredController
  private

  def find_resources_association_chain
    association_chain
  end

  def association_chain
    account.users.all
  end

  def filter_class
    Filter::Resource::User
  end

  def permitted_params
    params.permit(:email, :password, :metadata_merge_mode, :metadata => {})
  end

  def resource_location
    api_user_path(resource)
  end

  def account
    current_account.super_admin? && params[:account_id] && Account.find(params[:account_id]) || current_account
  end
end
