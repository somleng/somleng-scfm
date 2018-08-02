class Dashboard::SensorRulesController < Dashboard::AdminController
  private

  def association_chain
    if parent_resource
      parent_resource.sensor_rules
    else
      current_account.sensor_rules
    end
  end

  def parent_resource
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
end
