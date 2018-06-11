class Dashboard::UsersController < Dashboard::AdminController
  private

  def association_chain
    current_account.users
  end

  def permitted_params
    params.require(:user).permit(:roles, province_ids: [])
  end

  def resources_path
    dashboard_users_path
  end

  def show_location(resource)
    dashboard_user_path(resource)
  end
end
