class Dashboard::SensorRulesController < Dashboard::AdminController
  helper_method :sensor

  private

  def association_chain
    if sensor
      sensor.sensor_rules
    else
      current_account.sensor_rules
    end
  end

  def sensor
    @sensor ||= current_account.sensors.find_by(id: params[:sensor_id])
  end

  def permitted_params
    params.require(:sensor_rule).permit(:level, :alert_file)
  end

  def resources_path
    dashboard_sensor_sensor_rules_path(resource.sensor)
  end
end
