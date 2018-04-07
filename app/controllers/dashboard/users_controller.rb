class Dashboard::UsersController < Dashboard::BaseController
  def index
    @users = current_account.users.page(params[:page])
  end
end
