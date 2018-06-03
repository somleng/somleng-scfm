class Api::SensorsController < Api::FilteredController
  private

  def association_chain
    current_account.sensors
  end

  def filter_class
    Filter::Resource::Sensor
  end

  def find_resources_association_chain
    association_chain
  end

  def permitted_params
    params.permit(:external_id, :metadata_merge_mode, metadata: {})
  end
end
