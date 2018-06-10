class RemotePhoneCallEventObserver < ApplicationObserver
  DEFAULT_CALL_FLOW_LOGIC = "CallFlowLogic::HelloWorld".freeze

  attr_accessor :remote_phone_call_event

  def remote_phone_call_event_initialized(remote_phone_call_event)
    self.remote_phone_call_event = remote_phone_call_event
    setup_remote_phone_call_event!
  end

  private

  def setup_remote_phone_call_event!
    remote_phone_call_event.remote_call_id ||= details["CallSid"]
    remote_phone_call_event.remote_direction ||= details["Direction"]
    remote_phone_call_event.phone_call ||= find_or_initialize_phone_call
    phone_call.msisdn ||= details["From"]
    phone_call.contact ||= find_or_initialize_contact(phone_call.msisdn)
    phone_call.remote_status = details["CallStatus"]
    remote_phone_call_event.call_flow_logic ||= registered_call_flow_logic(phone_call.call_flow_logic) || DEFAULT_CALL_FLOW_LOGIC
    remote_phone_call_event.phone_call.call_flow_logic = remote_phone_call_event.call_flow_logic
  end

  def details
    remote_phone_call_event.details
  end

  def phone_call
    remote_phone_call_event.phone_call
  end

  def find_or_initialize_phone_call
    PhoneCall.where(
      remote_call_id: remote_phone_call_event.remote_call_id
    ).first_or_initialize(
      remote_direction: remote_phone_call_event.remote_direction
    )
  end

  def find_or_initialize_contact(msisdn)
    find_or_initialize_account.contacts.where_msisdn(msisdn).first_or_initialize
  end

  def find_or_initialize_account
    Account.by_platform_account_sid(details["AccountSid"]).first_or_initialize
  end

  def registered_call_flow_logic(call_flow_logic)
    if call_flow_logic
      CallFlowLogic::Base.registered.map(&:to_s).detect { |r| r == call_flow_logic }
    end
  end
end
