source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 6.0"

gem "aasm", github: "aasm/aasm"
gem "active_elastic_job", github: "samnang/active-elastic-job", branch: "upgrade_to_aws_sdk_3"
gem "api-pagination", github: "davidcelis/api-pagination"
gem "aws-sdk-s3", require: false
gem "bitmask_attributes", github: "numerex/bitmask_attributes"
gem "bootsnap", require: false
gem "bootstrap"
gem "breadcrumbs_on_rails"
gem "cocoon"
gem "coffee-rails"
gem "devise"
gem "devise-async"
gem "devise_invitable"
gem "doorkeeper", github: "doorkeeper-gem/doorkeeper"
gem "down"
gem "dry-validation", "~> 0.13.3"
gem "faraday"
gem "file_validators"
gem "font-awesome-rails"
gem "haml-rails"
gem "jbuilder", "~> 2.5"
gem "jquery-rails"
gem "kaminari"
gem "octicons_helper"
gem "okcomputer"
gem "pg"
gem "phony"
gem "phony_rails"
gem "puma"
gem "record_tag_helper", github: "rails/record_tag_helper"
gem "responders"
gem "sass-rails", "~> 5"
gem "sassc"
gem "sentry-raven"
gem "simple_form"
gem "strip_attributes"
gem "turbolinks", "~> 5"
gem "twilio-ruby"
gem "uglifier", ">= 1.3.0"
gem "webpacker", "~> 4.0"
gem "wisper", github: "krisleech/wisper"

group :development, :test do
  gem "i18n-tasks"
  gem "pry"
  gem "rspec-rails", ">= 4.0.0.beta2"
  gem "rubocop"
  gem "rubocop-rspec"
  gem "rubocop-rails"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara"
  gem "codecov", require: false
  gem "email_spec"
  gem "factory_bot_rails"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "shoulda-matchers", github: "thoughtbot/shoulda-matchers"
  gem "simplecov", require: false
  gem "webdrivers"
  gem "webmock"
  gem "wisper-rspec"
end
