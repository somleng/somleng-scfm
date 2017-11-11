class Filter::Resource::PhoneCall < Filter::Resource::Msisdn
  def self.attribute_filters
    super <<
     :remote_response_attribute_filter <<
     :remote_queue_response_attribute_filter <<
     :remote_request_params_attribute_filter
  end

  private

  def remote_response_attribute_filter
    @remote_response_attribute_filter ||= build_json_attribute_filter(:remote_response)
  end

  def remote_queue_response_attribute_filter
    @remote_queue_response_attribute_filter ||= build_json_attribute_filter(:remote_queue_response)
  end

  def remote_request_params_attribute_filter
    @remote_request_params_attribute_filter ||= build_json_attribute_filter(:remote_request_params)
  end

  def build_json_attribute_filter(json_attribute)
    Filter::Attribute::JSON.new(
      {
        :json_attribute => json_attribute
      }.merge(options), params
    )
  end

  def filter_params
    params.slice(
      :callout_participation_id,
      :contact_id,
      :status,
      :remote_call_id,
      :remote_status,
      :remote_direction,
      :remote_error_message
    )
  end
end

