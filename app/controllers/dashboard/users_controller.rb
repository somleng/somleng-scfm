class Dashboard::UsersController < Dashboard::BaseController
  before_action :authorize_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = current_account.users.page(params[:page])
  end

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to dashboard_user_url(@user), notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy

    redirect_to dashboard_users_url, notice: 'User was successfully destroyed.'
  end

  private

  def set_user
    @user = current_account.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:id, roles: [])
  end
end
