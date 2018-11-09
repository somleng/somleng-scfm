class CallFlowLogic::Base
  attr_accessor :options

  def self.registered
    @registered ||= descendants.reject(&:abstract_class?).map(&:to_s)
  end

  def self.abstract_class?
    false
  end

  def initialize(options = {})
    self.options = options
  end

  def event
    options[:event]
  end

  def run!
    event&.phone_call_complete!
  end
end

require_relative "hello_world"
require_relative "play_message"
