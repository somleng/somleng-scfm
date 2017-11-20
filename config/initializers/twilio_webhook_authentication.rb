require 'twilio-ruby'

platform_provider = ENV["PLATFORM_PROVIDER"] || "TWILIO"
auth_token_key = "#{platform_provider}_AUTH_TOKEN".upcase

Rails.application.config.middleware.use(
  Rack::SomlengWebhookAuthentication,
  ENV[auth_token_key],
  "api/remote_phone_call_events",
  :methods => :post
) { |account_sid| ENV[auth_token_key] }
