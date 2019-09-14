module RequestSchemaMatchers
  extend RSpec::Matchers::DSL

  module Helpers
    def valid?(actual, *path)
      actual.errors.to_h.dig(*path).blank?
    end

    def invalid?(actual, *path)
      options = path.extract_options!
      errors = actual.errors.to_h.dig(*path)
      return false if errors.blank?
      return true if options[:error_message].blank?

      errors.any? { |err| err.match?(options.fetch(:error_message)) }
    end
  end

  matcher :have_valid_field do |*path|
    include Helpers

    match { |actual| valid?(actual, *path) }
    match_when_negated { |actual| invalid?(actual, *path) }
  end
end

RSpec.configure do |config|
  config.include RequestSchemaMatchers, type: :request_schema
end
