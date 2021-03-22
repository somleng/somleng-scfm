module CallFlowLogic
  class Base
    attr_accessor :options

    RETRY_CALL_STATUSES = %w[not_answered busy failed canceled expired].freeze

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
      retry_call
    rescue ActiveRecord::StaleObjectError
      event.phone_call.reload
      retry
    end

    private

    def retry_call
      return unless phone_call.status.in?(RETRY_CALL_STATUSES)
      return if callout_participation.blank?
      return if callout_participation.phone_calls_count >= phone_call.account.max_phone_calls_for_callout_participation

      RetryPhoneCallJob.set(wait: 15.minutes).perform_later(phone_call)
    end

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
