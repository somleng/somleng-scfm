class Dashboard::LocalesController < Dashboard::BaseController
  private

  def find_resource
    @resource = current_user
  end

  def permitted_params
    params.fetch(:user, {}).permit(:locale)
  end

  def respond_with_updated_resource
    redirect_back(fallback_location: root_path)
  end
end
