source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "aasm", github: "aasm/aasm"
gem "active_elastic_job", github: "samnang/active-elastic-job", branch: "upgrade_to_aws_sdk_3"
gem "api-pagination", github: "davidcelis/api-pagination"
gem "aws-sdk-s3", require: false
gem "bitmask_attributes", github: "numerex/bitmask_attributes"
gem "bootsnap", ">= 1.1.0", require: false
gem "bootstrap", "~> 4.1.1"
gem "breadcrumbs_on_rails"
gem "cocoon"
gem "coffee-rails", "~> 4.2"
gem "devise"
gem "devise-async"
gem "devise_invitable"
gem "doorkeeper"
gem "file_validators"
gem "font-awesome-rails"
gem "haml"
gem "jbuilder", "~> 2.5"
gem "jquery-rails"
gem "kaminari"
gem "octicons_helper"
gem "okcomputer"
gem "pg"
gem "phony"
gem "phony_rails"
gem "puma", "~> 3.7"
gem "rails", "~> 5.2.1"
gem "record_tag_helper", "~> 1.0"
gem "responders"
gem "sass-rails", "~> 5.0"
gem "sentry-raven"
gem "simple_form"
gem "turbolinks", "~> 5"
gem "twilio-ruby"
gem "uglifier", ">= 1.3.0"
gem "wisper", github: "krisleech/wisper"

group :development, :test do
  gem "i18n-tasks"
  gem "pry"
  gem "rspec-rails"
  gem "rubocop"
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
  gem "chromedriver-helper"
  gem "codecov", require: false
  gem "email_spec"
  gem "factory_bot_rails"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "shoulda-matchers", github: "thoughtbot/shoulda-matchers"
  gem "simplecov", require: false
  gem "webmock"
  gem "wisper-rspec"
end
