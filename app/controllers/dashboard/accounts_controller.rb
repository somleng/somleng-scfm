class Dashboard::AccountsController < Dashboard::AdminController
  private

  def find_resource
    @resource = current_account
  end

  def permitted_params
    params.require(:account).permit(
      :platform_provider_name,
      :twilio_account_sid,
      :twilio_auth_token,
      :somleng_account_sid,
      :somleng_auth_token
    )
  end

  def show_location(_resource)
    edit_dashboard_account_path
  end
end
