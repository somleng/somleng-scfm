class RemotePhoneCallEvent < ApplicationRecord
  DEFAULT_CALL_FLOW_LOGIC = CallFlowLogic::Application

  include MetadataHelpers
  include HasCallFlowLogic
  conditionally_serialize(:details, JSON)

  belongs_to :phone_call, :validate => true, :autosave => true
  before_validation :set_defaults, :on => :create

  validates :call_flow_logic,
            :presence => true

  validates :remote_call_id,
            :remote_direction,
            :presence => true

  delegate :contact, :remote_status, :remote_status=, :to => :phone_call
  delegate :complete!, :to => :phone_call, :prefix => true

  def from=(value)
    phone_call.msisdn = value
  end

  def from
    phone_call.msisdn
  end

  private

  def set_defaults
    self.remote_call_id ||= details["CallSid"]
    self.remote_direction ||= details["Direction"]
    self.phone_call ||= find_or_initialize_phone_call
    self.from ||= details["From"]
    self.remote_status ||= details["CallStatus"]
    self.call_flow_logic ||= registered_call_flow_logic(phone_call.call_flow_logic) || default_call_flow_logic
    self.phone_call.call_flow_logic = call_flow_logic
  end

  def find_or_initialize_phone_call
    PhoneCall.where(:remote_call_id => remote_call_id).first_or_initialize(
      :remote_direction => remote_direction
    )
  end

  def registered_call_flow_logic(call_flow_logic)
    if call_flow_logic
      CallFlowLogic::Base.registered.map(&:to_s).detect { |r| r == call_flow_logic }
    end
  end

  def default_call_flow_logic
    registered_call_flow_logic(ENV["DEFAULT_CALL_FLOW_LOGIC"]) || DEFAULT_CALL_FLOW_LOGIC
  end
end
