class Api::SensorEventsController < Api::FilteredController
  private

  def association_chain
    if sensor_id
      sensor.sensor_events
    elsif sensor_rule_id
      sensor_rule.sensor_events
    else
      current_account.sensor_events
    end
  end

  def setup_resource
    resource.authorized_account = current_account
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

  def filter_class
    Filter::Resource::SensorEvent
  end

  def find_resources_association_chain
    association_chain
  end

  def permitted_params
    params.permit(payload: {})
  end
end
