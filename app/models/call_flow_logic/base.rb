class CallFlowLogic::Base
  attr_accessor :options

  def self.registered(reload: false)
    @registered = (!reload && @registered) || descendants.reject(&:abstract_class?).map(&:to_s)
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

  def current_url
    options[:current_url]
  end

  def run!
    event&.phone_call_complete!
  end

  def no_response
    Twilio::TwiML::VoiceResponse.new do |response|
      response.say("Sorry. The application has no response. Goodbye.")
    end.to_s
  end
end
