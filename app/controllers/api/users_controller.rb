class Api::UsersController < Api::FilteredController
  private

  def find_resources_association_chain
    association_chain
  end

  def association_chain
    User.all
  end

  def filter_class
    Filter::Resource::User
  end

  def permitted_params
    params.permit(:email, :password, :account_id, :metadata_merge_mode, :metadata => {})
  end

  def resource_location
    api_user_path(resource)
  end
end
