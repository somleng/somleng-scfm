class Dashboard::UsersController < Dashboard::BaseController
  def index
    @user = current_account.users.all
  end
end
