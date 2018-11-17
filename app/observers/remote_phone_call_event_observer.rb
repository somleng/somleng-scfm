class RemotePhoneCallEventObserver < ApplicationObserver
  def remote_phone_call_event_initialized(event)
    process_event(event)
  end

  private

  def process_event(event)
    call_duration = event.details.fetch("CallDuration") { 0 }
    event.remote_call_id = event.details.fetch("CallSid")
    event.remote_direction = event.details.fetch("Direction")
    event.call_duration = call_duration
    event.phone_call ||= find_or_initialize_phone_call(event)
    event.phone_call.msisdn ||= event.details.fetch("From")
    event.phone_call.remote_status = event.details.fetch("CallStatus")
    event.phone_call.duration = call_duration if event.phone_call.duration.zero?
    event.phone_call.contact ||= find_or_initialize_contact(
      event.details.fetch("AccountSid"),
      event.phone_call.msisdn
    )
    event.phone_call.set_call_flow_logic
    event.call_flow_logic ||= event.phone_call.call_flow_logic
  end

  def find_or_initialize_phone_call(event)
    PhoneCall.where(
      remote_call_id: event.remote_call_id
    ).first_or_initialize(
      remote_direction: event.remote_direction
    )
  end

  def find_or_initialize_contact(platform_account_sid, msisdn)
    find_or_initialize_account(
      platform_account_sid
    ).contacts.where_msisdn(msisdn).first_or_initialize
  end

  def find_or_initialize_account(platform_account_sid)
    Account.by_platform_account_sid(platform_account_sid).first_or_initialize
  end
end
