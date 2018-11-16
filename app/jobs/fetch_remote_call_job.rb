class FetchRemoteCallJob < ApplicationJob
  def perform(phone_call_id)
    phone_call = PhoneCall.find(phone_call_id)

    return unless phone_call.remote_call_id?

    response = fetch_remote_call(phone_call)

    phone_call.update!(
      remote_response: response.instance_variable_get(:@properties).compact,
      remote_status: response.status
    )

    phone_call.complete!
  end

  private

  def fetch_remote_call(phone_call)
    Somleng::Client.new(
      provider: phone_call.platform_provider
    ).api.calls(phone_call.remote_call_id).fetch
  end
end
