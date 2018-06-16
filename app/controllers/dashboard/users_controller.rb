class Dashboard::UsersController < Dashboard::AdminController
  private

  def association_chain
    current_account.users
  end

  def permitted_params
    params.require(:user).permit(:roles, location_ids: [])
  end
end
