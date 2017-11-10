require 'twilio-ruby'

Rails.application.config.middleware.use(
  Rack::TwilioWebhookAuthentication,
  ENV["TWILIO_REQUEST_AUTH_TOKEN"],
  "api/remote_phone_call_events"
) { |account_sid| ENV["TWILIO_REQUEST_AUTH_TOKEN"] }
