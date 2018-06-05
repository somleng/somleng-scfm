class Dashboard::LocalesController < Dashboard::BaseController
  before_action :authorize_owner!

  private

  def association_chain
    current_account.users
  end

  def permitted_params
    params.fetch(:user, {}).permit(:locale)
  end

  def respond_with_updated_resource
    redirect_back(fallback_location: root_path)
  end

  def authorize_owner!
    (resource == current_user)
  end
end
