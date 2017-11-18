class CallFlowLogic::Base
  DEFAULT = "CallFlowLogic::Application"

  attr_accessor :options
  @registered = [DEFAULT]

  def self.registered
    @registered
  end

  def self.register(*args)
    @registered += args.compact
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
  end

  def no_response
    Twilio::TwiML::VoiceResponse.new do |response|
      response.say("Sorry. The application has no response. Goodbye.")
    end.to_s
  end
end
