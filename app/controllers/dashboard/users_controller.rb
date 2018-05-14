class Dashboard::UsersController < Dashboard::BaseController
  private

  def association_chain
    current_account.users
  end
end
