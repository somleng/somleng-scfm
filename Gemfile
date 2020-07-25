source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "6.0.2.1"

gem "aasm", github: "aasm/aasm"
gem "after_commit_everywhere"
gem "api-pagination", github: "davidcelis/api-pagination"
gem "aws-sdk-s3", require: false
gem "aws-sdk-sqs"
gem "bitmask_attributes", github: "numerex/bitmask_attributes"
gem "bootsnap", require: false
gem "breadcrumbs_on_rails"
gem "cocoon"
gem "devise"
gem "devise-async"
gem "devise_invitable"
gem "doorkeeper"
gem "down"
gem "dry-validation"
gem "faraday"
gem "file_validators"
gem "haml-rails"
gem "jbuilder", "~> 2.5"
gem "kaminari"
gem "okcomputer"
gem "pg"
gem "phony"
gem "phony_rails"
gem "puma"
gem "pumi", github: "dwilkie/pumi"
gem "record_tag_helper", github: "rails/record_tag_helper"
gem "responders"
gem "sassc-rails"
gem "sentry-raven"
gem "shoryuken"
gem "simple_form"
gem "strip_attributes"
gem "turbolinks", "~> 5"
gem "twilio-ruby"
gem "webpacker"
gem "wisper", github: "krisleech/wisper"

group :development, :test do
  gem "i18n-tasks"
  gem "pry"
  gem "rspec_api_documentation", github: "samnang/rspec_api_documentation"
  gem "rspec-rails", ">= 4.0.0.beta2"
  gem "rubocop"
  gem "rubocop-rails"
  gem "rubocop-rspec"
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
  gem "shoulda-matchers", github: "thoughtbot/shoulda-matchers"
  gem "simplecov", require: false
  gem "webdrivers"
  gem "webmock"
  gem "wisper-rspec"
end
