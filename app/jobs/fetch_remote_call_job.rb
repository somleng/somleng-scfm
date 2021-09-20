class FetchRemoteCallJob < ApplicationJob
  queue_as Rails.configuration.app_settings.fetch(:aws_sqs_low_priority_queue_name)

  def perform(phone_call)
    return unless phone_call.status.to_sym.in?(PhoneCall::IN_PROGRESS_STATUSES)

    response = Somleng::Client.new(
      provider: phone_call.platform_provider
    ).api.calls(phone_call.remote_call_id).fetch

    attributes = {
      remote_response: response.instance_variable_get(:@properties).compact,
      remote_status: response.status,
      duration: response.duration,
    }.compact

    phone_call.update!(remote_status_fetch_queued_at: nil, **attributes)

    event = RemotePhoneCallEvent.new(phone_call: phone_call)
    phone_call.call_flow_logic.constantize.new(event: event).run!
  end
end
