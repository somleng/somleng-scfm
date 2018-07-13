class Filter::Resource::SensorEvent < Filter::Resource::Base
  def self.attribute_filters
    super.reject { |e| e == :metadata_attribute_filter } << :payload_attribute_filter
  end

  private

  def payload_attribute_filter
    Filter::Attribute::JSON.new(
      { json_attribute: :payload }.merge(options),
      params
    )
  end

  def filter_params
    params.slice(
      :sensor_id,
      :sensor_rule_id
    )
  end
end
