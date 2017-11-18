class CallFlowLogic::Base
  attr_accessor :remote_phone_call_event
  @registered = []

  def self.registered
    @registered
  end

  def self.register(*args)
    @registered += args
  end

  def initialize(remote_phone_call_event)
    self.remote_phone_call_event = remote_phone_call_event
  end

  def run!
  end
end
