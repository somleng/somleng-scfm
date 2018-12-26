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
    RemotePhoneCallEvent.transaction do
      event = build_event
      event.save!
      event
    end
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
    event.phone_call ||= create_or_find_phone_call!(event)
    event.phone_call.remote_status = params.fetch(:CallStatus)
    event.phone_call.duration = call_duration if event.phone_call.duration.zero?
    event.call_flow_logic ||= event.phone_call.call_flow_logic
    event
  end

  def resolve_call_flow_logic(event)
    event.call_flow_logic.constantize.new(
      event: event, current_url: url
    )
  end

  def create_or_find_phone_call!(event)
    PhoneCall.create_or_find_by!(remote_call_id: event.remote_call_id) do |phone_call|
      phone_call.remote_direction = event.remote_direction
      phone_call.msisdn = phone_call.inbound? ? params.fetch(:From) : params.fetch(:To)
      phone_call.contact = create_or_find_contact!(params.fetch(:AccountSid), phone_call.msisdn)
    end
  end

  def create_or_find_contact!(platform_account_sid, msisdn)
    account = Account.find_by_platform_account_sid(platform_account_sid)
    Contact.create_or_find_by!(account: account, msisdn: PhonyRails.normalize_number(msisdn))
  end
end
