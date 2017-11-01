require 'webmock/rspec'
require_relative 'setup_scenario'

# From: https://gist.github.com/2596158
# Thankyou Bartosz Blimke!
# https://twitter.com/bartoszblimke/status/198391214247124993

module WebMockLastRequest
  def clear_requests!
    @requests = nil
  end

  def requests
    @requests ||= []
  end

  def last_request=(request_signature)
    requests << request_signature
    request_signature
  end
end

WebMock.extend(WebMockLastRequest)

WebMock.after_request do |request_signature, response|
  WebMock.last_request = request_signature
end

module WebMockHelpers
  include SetupScenario

  def setup_scenario
    super
    WebMock.clear_requests!
  end
end

RSpec.configure do |config|
  config.include(WebMockHelpers)
end

