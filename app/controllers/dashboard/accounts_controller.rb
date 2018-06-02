class Dashboard::AccountsController < Dashboard::AdminController
  private

  def find_resource
    @resource = current_account
  end

  def permitted_params
    params.require(:account).permit(
      :platform_provider_name,
      :call_flow_logic,
      :twilio_account_sid,
      :twilio_auth_token,
      :somleng_account_sid,
      :somleng_auth_token,
      settings_fields_attributes: KEY_VALUE_FIELD_ATTRIBUTES
    )
  end

  def show_location(_resource)
    edit_dashboard_account_path
  end

  def before_update_attributes
    resource.settings.clear
  end

  def build_key_value_fields
    resource.build_settings_field if resource.settings_fields.empty?
  end
end
