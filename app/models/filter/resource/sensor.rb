class Filter::Resource::Sensor < Filter::Resource::Base
  private

  def filter_params
    params.slice(:external_id)
  end
end
