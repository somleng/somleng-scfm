class FetchRemoteCallJob < ApplicationJob
  def perform(phone_call)
    response = Somleng::Client.new(
      provider: phone_call.platform_provider
    ).api.calls(phone_call.remote_call_id).fetch

    attributes = {
      remote_response: response.instance_variable_get(:@properties).compact,
      remote_status: response.status,
      duration: response.duration
    }.compact
    phone_call.update!(attributes)

    event = RemotePhoneCallEvent.new(phone_call: phone_call)
    phone_call.call_flow_logic.constantize.new(event: event).run!
  end
end
