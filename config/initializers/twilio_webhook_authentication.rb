require 'twilio-ruby'

Rails.application.config.middleware.use(
  Rack::SomlengWebhookAuthentication,
  nil,
  "api/remote_phone_call_events",
  :methods => :post
) do |account_sid|
  account = Account.by_platform_account_sid(account_sid).first
  account && account.platform_auth_token(account_sid)
end
