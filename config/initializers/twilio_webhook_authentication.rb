require 'twilio-ruby'

Rails.application.config.middleware.use(
  Rack::SomlengWebhookAuthentication,
  ENV["TWILIO_REQUEST_AUTH_TOKEN"],
  "api/remote_phone_call_events",
  :methods => :post
) { |account_sid| ENV["TWILIO_REQUEST_AUTH_TOKEN"] }
