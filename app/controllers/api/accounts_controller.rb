class Api::AccountsController < Api::FilteredController
  before_action :authorize_super_admin!

  private

  def singleton?
    !params[:id]
  end

  def authorize_super_admin!
    super if %w[show update].exclude?(action_name) || !singleton?
  end

  def find_resource
    !singleton? && super || @resource = current_account
  end

  def find_resources_association_chain
    association_chain
  end

  def association_chain
    Account.all
  end

  def filter_class
    Filter::Resource::Account
  end

  def permitted_params
    params.permit(
      :platform_provider_name,
      :twilio_account_sid,
      :twilio_auth_token,
      :somleng_account_sid,
      :somleng_auth_token,
      :metadata_merge_mode,
      :call_flow_logic,
      settings: {},
      metadata: {}
    )
  end

  def resource_location
    api_account_path(resource)
  end
end
