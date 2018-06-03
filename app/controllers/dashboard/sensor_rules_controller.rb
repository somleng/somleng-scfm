class Dashboard::SensorRulesController < Dashboard::AdminController
  helper_method :parent_show_path, :sensor

  private

  def association_chain
    if parent
      parent.sensor_rules
    else
      current_account.sensor_rules
    end
  end

  def parent
    sensor if sensor_id
  end

  def sensor_id
    params[:sensor_id]
  end

  def sensor
    @sensor ||= current_account.sensors.find(sensor_id)
  end

  def permitted_params
    params.require(:sensor_rule).permit(:level, :alert_file)
  end

  def resources_path
    dashboard_sensor_sensor_rules_path(resource.sensor)
  end

  def parent_show_path
    polymorphic_path([:dashboard, parent]) if parent
  end
end
