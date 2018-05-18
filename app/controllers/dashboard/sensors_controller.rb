class Dashboard::SensorsController < Dashboard::AdminController
  private

  def association_chain
    current_account.sensors
  end

  def permitted_params
    params.require(:sensor).permit(
      :province_id, sensor_rules_attributes: %i[id level voice _destroy]
    )
  end

  def resources_path
    dashboard_sensors_path
  end

  def prepare_new_resource
    resource.sensor_rules.new
  end
end
