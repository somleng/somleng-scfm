class QueueRemoteCallJob < ApplicationJob
  include Rails.application.routes.url_helpers

  attr_accessor :phone_call

  def perform(phone_call)
    begin
      somleng_client = Somleng::Client.new(provider: phone_call.platform_provider)
      response = somleng_client.api.account.calls.create(
        to: phone_call.msisdn,
        from: phone_call.account.from_phone_number,
        url: api_remote_phone_call_events_url(protocol: :https),
        status_callback: api_remote_phone_call_events_url(protocol: :https)
      )
      phone_call.remote_queue_response = response.instance_variable_get(:@properties).compact
      phone_call.remote_status = response.status
      phone_call.remote_call_id = response.sid
      phone_call.remote_direction = response.direction
    rescue Twilio::REST::RestError => e
      phone_call.remote_error_message = e.message
    end

    phone_call.queue_remote!
  end
end
