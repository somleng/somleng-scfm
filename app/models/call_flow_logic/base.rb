class CallFlowLogic::Base
  attr_accessor :remote_phone_call_event

  def initialize(remote_phone_call_event)
    self.remote_phone_call_event = remote_phone_call_event
  end

  def run!
  end
end
