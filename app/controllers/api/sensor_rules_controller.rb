class Api::SensorRulesController < Api::BaseController
  private

  def association_chain
    if sensor_id
      sensor.sensor_rules
    else
      current_account.sensor_rules
    end
  end

  def sensor_id
    params[:sensor_id]
  end

  def sensor
    @sensor ||= current_account.sensors.find(sensor_id)
  end

  def filter_class
    Filter::Resource::SensorRule
  end

  def find_resources_association_chain
    association_chain
  end

  def permitted_params
    params.permit(:alert_file, :level, :metadata_merge_mode, metadata: {})
  end
end
