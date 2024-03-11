require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "sprockets/railtie"
# require "action_cable/engine"
# require "action_mailbox/engine"
# require "action_text/engine"
# require "rails/test_unit/railtie"

require_relative "../app/middleware/rack/somleng_webhook_authentication"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SomlengScfm
  class Application < Rails::Application
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.eager_load_paths << Rails.root.join("lib")

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.app_settings = config_for(:app_settings)
    config.active_job.default_queue_name = config.app_settings.fetch(:aws_sqs_default_queue_name)
    Rails.application.routes.default_url_options[:host] =
      config.app_settings.fetch(:default_url_host)

    config.middleware.use(
      Rack::SomlengWebhookAuthentication,
      nil,
      "/twilio_webhooks",
      methods: :post
    ) do |account_sid|
      account = Account.find_by_platform_account_sid(account_sid)
      account&.platform_auth_token(account_sid)
    end
  end
end

require "administrate_extensions"
require "api_pagination_with_preloaded_total_count"
