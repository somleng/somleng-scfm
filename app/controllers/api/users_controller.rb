class Api::UsersController < Api::FilteredController
  private

  def find_resources_association_chain
    association_chain
  end

  def association_chain
    specified_or_current_account.users.all
  end

  def filter_class
    Filter::Resource::User
  end

  def permitted_params
    params.permit(:email, :password, :metadata_merge_mode, :metadata => {})
  end
end
