class Dashboard::UsersController < Dashboard::BaseController
  private

  def association_chain
    current_account.users
  end

  def build_key_value_fields
    build_metadata_field
  end

  def permitted_params
    params.fetch(:user, {}).permit(METADATA_FIELDS_ATTRIBUTES)
  end

  def resources_path
    dashboard_users_path
  end

  def show_location(resource)
    dashboard_user_path(resource)
  end
end
