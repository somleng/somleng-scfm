class Dashboard::SensorsController < Dashboard::AdminController
  private

  def association_chain
    current_account.sensors
  end

  def permitted_params
    params.require(:sensor).permit(
      :external_id,
      commune_ids: [],
      **METADATA_FIELDS_ATTRIBUTES
    )
  end

  def resources_path
    dashboard_sensors_path
  end

  def build_key_value_fields
    resource.build_metadata_field if resource.metadata_fields.empty?
  end

  def before_update_attributes
    clear_metadata
  end
end
