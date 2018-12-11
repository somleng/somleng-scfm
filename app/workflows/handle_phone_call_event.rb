class HandlePhoneCallEvent < ApplicationWorkflow
  attr_accessor :url, :params

  def initialize(url, params = {})
    self.url = url
    self.params = params
  end

  def call
    event = create_event
    return event if event.errors.any?

    run_call_flow!(event)
  end

  private

  def create_event
    event = build_event
    event.save
    event
  rescue ActiveRecord::StaleObjectError
    retry
  end

  def run_call_flow!(event)
    call_flow_logic = resolve_call_flow_logic(event)
    call_flow_logic.run!
    call_flow_logic
  end

  def build_event
    event = RemotePhoneCallEvent.new(details: params)
    call_duration = params.fetch(:CallDuration) { 0 }
    event.remote_call_id = params.fetch(:CallSid)
    event.remote_direction = params.fetch(:Direction)
    event.call_duration = call_duration
    event.phone_call ||= find_or_initialize_phone_call(event)
    event.phone_call.msisdn ||= params.fetch(:From)
    event.phone_call.remote_status = params.fetch(:CallStatus)
    event.phone_call.duration = call_duration if event.phone_call.duration.zero?
    event.phone_call.contact ||= find_or_initialize_contact(
      params.fetch(:AccountSid),
      event.phone_call.msisdn
    )
    event.phone_call.set_call_flow_logic
    event.call_flow_logic ||= event.phone_call.call_flow_logic
    event
  end

  def resolve_call_flow_logic(event)
    event.call_flow_logic.constantize.new(
      event: event, current_url: url
    )
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
