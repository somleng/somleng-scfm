source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 5.2.0"
# support both sqlite3 and pg
gem "aasm", github: "aasm/aasm"
gem "active_elastic_job", github: "tawan/active-elastic-job"
gem "api-pagination"
gem "bitmask_attributes", github: "numerex/bitmask_attributes"
gem "bootsnap", ">= 1.1.0", require: false
gem "bootstrap", "~> 4.0.0"
gem "coffee-rails", "~> 4.2"
gem "devise"
gem "devise-async"
gem "devise_invitable"
gem "doorkeeper"
gem "haml"
gem "httparty"
gem "jbuilder", "~> 2.5"
gem "jquery-rails"
gem "kaminari"
gem "octicons_helper"
gem "okcomputer"
gem "pg"
gem "phony"
gem "phony_rails"
gem "puma"
gem "pumi", github: "dwilkie/pumi", require: "pumi/rails"
gem "record_tag_helper", "~> 1.0"
gem "responders"
gem "sass-rails", "~> 5.0"
gem "simple_form"
gem "sqlite3"
gem "turbolinks", "~> 5"
gem "twilio-ruby"
gem "uglifier", ">= 1.3.0"
gem "wisper", github: "krisleech/wisper"

group :development, :test do
  gem "pry"
  gem "rspec-rails"
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
  gem 'selenium-webdriver'
  gem "codeclimate-test-reporter", "~> 1.0.0"
  gem "email_spec"
  gem "factory_bot_rails"
  gem "fakefs", require: "fakefs/safe"
  gem "rails-controller-testing"
  gem "shoulda-matchers", github: "thoughtbot/shoulda-matchers"
  gem "simplecov", require: false
  gem "webmock"
  gem "wisper-rspec"
end
