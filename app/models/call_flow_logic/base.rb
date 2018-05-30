class CallFlowLogic::Base
  DEFAULT = "CallFlowLogic::HelloWorld".freeze

  attr_accessor :options

  def self.init
    names = Rails.application.secrets[:registered_call_flow_logic]
    return if names.blank?

    class_names = names.to_s.split(",").each_with_object([]) do |name, result|
      name.constantize
      result << name.to_s
    rescue StandardError
      nil
    end

    register(*class_names)
  end

  def self.registered
    @registered ||= [DEFAULT]
  end

  def self.register(*args)
    args.each do |arg|
      registered << arg if arg && permitted.include?(arg)
    end
    registered
  end

  def self.permitted
    CallFlowLogic::Base.descendants.map(&:to_s)
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

CallFlowLogic::Base.init
