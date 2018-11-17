class Filter::Resource::RemotePhoneCallEvent < Filter::Resource::Base
  def self.attribute_filters
    super << :details_attribute_filter <<
      :call_duration_attribute_filter
  end

  private

  def details_attribute_filter
    Filter::Attribute::JSON.new(
      { json_attribute: :details }.merge(options), params
    )
  end

  def call_duration_attribute_filter
    Filter::Attribute::Duration.new(
      { duration_column: :call_duration }.merge(options), params
    )
  end

  def filter_params
    params.slice(
      :phone_call_id,
      :call_flow_logic,
      :remote_call_id,
      :remote_direction,
      :call_duration
    )
  end
end
