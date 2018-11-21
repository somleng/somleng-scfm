class FetchRemoteCallJob < ApplicationJob
  def perform(phone_call_id)
    phone_call = PhoneCall.find(phone_call_id)

    return unless phone_call.remote_call_id?

    response = fetch_remote_call(phone_call)

    attributes = {
      remote_response: response.instance_variable_get(:@properties).compact,
      remote_status: response.status,
      duration: response.duration
    }.compact

    phone_call.update!(attributes)
    call_flow_logic(phone_call).run!
  end

  private

  def call_flow_logic(phone_call)
    event = RemotePhoneCallEvent.new(phone_call: phone_call)
    phone_call.call_flow_logic.constantize.new(event: event)
  end

  def fetch_remote_call(phone_call)
    Somleng::Client.new(
      provider: phone_call.platform_provider
    ).api.calls(phone_call.remote_call_id).fetch
  end
end
