class Dashboard::CalloutsController < Dashboard::BaseController
  private

  def association_chain
    current_account.callouts
  end

  def permitted_params
    params.fetch(:callout, {}).permit(
      :call_flow_logic,
      :audio_file,
      :audio_url,
      **METADATA_FIELDS_ATTRIBUTES
    )
  end

  def before_update_attributes
    clear_metadata
  end

  def resources_path
    dashboard_callouts_path
  end

  def build_key_value_fields
    build_metadata_field
  end
end
