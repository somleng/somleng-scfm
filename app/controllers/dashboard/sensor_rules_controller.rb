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
    params.require(:sensor_rule).permit(:level, :voice)
  end

  def resources_path
    dashboard_sensor_sensor_rules_path(resource.sensor)
  end

  def respond_with_created_resource
    location = polymorphic_path([:dashboard, resource.sensor, :sensor_rules])
    respond_with_resource(location: location)
  end
end
