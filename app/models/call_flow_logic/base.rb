module CallFlowLogic
  class Base
    attr_accessor :options

    MAX_PHONE_CALLS_COUNT = 3
    RETRY_CALL_STATUSES = %i[not_answered busy failed].freeze

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
      phone_call.complete!
      return if phone_call.inbound?
      return if callout_participation.phone_calls_count >= MAX_PHONE_CALLS_COUNT
      return unless phone_call.status.in?(RETRY_CALL_STATUSES)

      RetryPhoneCallJob.set(wait: 15.minutes).perform_later
    rescue ActiveRecord::StaleObjectError
      event.phone_call.reload
      retry
    end

    private

    def phone_call
      event.phone_call
    end

    def callout_participation
      phone_call.callout_participation
    end
  end
end

require_relative "hello_world"
require_relative "play_message"
