class CallFlowLogic::Base
  attr_accessor :phone_call_event

  def initialize(phone_call_event)
    self.phone_call_event = phone_call_event
  end

  def run!
  end
end
