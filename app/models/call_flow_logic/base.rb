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
    options.fetch(:event)
  end

  def current_url
    options.fetch(:current_url)
  end

  def run!
    event&.phone_call_complete!
  end

  def remote_request_params
    phone_call.remote_request_params.merge("to" => phone_call.msisdn)
  end

  private

  def phone_call
    options.fetch(:phone_call)
  end
end

require_relative "hello_world"
require_relative "play_message"
