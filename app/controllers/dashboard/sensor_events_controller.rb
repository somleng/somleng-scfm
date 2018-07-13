class Dashboard::SensorEventsController < Dashboard::AdminController
  helper_method :parent_show_path

  private

  def association_chain
    if parent
      parent.sensor_events
    else
      current_account.sensor_events
    end
  end

  def parent
    if sensor_id
      sensor
    elsif sensor_rule_id
      sensor_rule
    end
  end

  def sensor_id
    params[:sensor_id]
  end

  def sensor
    @sensor ||= current_account.sensors.find(sensor_id)
  end

  def sensor_rule_id
    params[:sensor_rule_id]
  end

  def sensor_rule
    @sensor_rule ||= current_account.sensor_rules.find(sensor_rule_id)
  end

  def parent_show_path
    polymorphic_path([:dashboard, parent]) if parent
  end
end
