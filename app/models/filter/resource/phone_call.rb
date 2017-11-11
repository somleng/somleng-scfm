class Filter::Resource::PhoneCall < Filter::Resource::Base
  def self.attribute_filters
    super << :remote_response_attribute_filter
  end

  private

  def remote_response_attribute_filter
    @remote_response_attribute_filter ||= Filter::Attribute::RemoteResponse.new(options, params)
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

