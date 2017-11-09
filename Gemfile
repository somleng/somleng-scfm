source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.4'
# support both sqlite3 and pg
gem 'pg'
gem 'sqlite3'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'aasm', :github => "aasm/aasm"
gem 'phony_rails'
gem 'phony'
gem 'twilio-ruby'
gem 'httparty'
gem 'responders'
gem 'kaminari'
gem 'api-pagination'
gem 'wisper', :github => "krisleech/wisper"
gem 'active_elastic_job', :github => 'tawan/active-elastic-job'

group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'webmock'
  gem 'simplecov', :require => false
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem "fakefs", :require => 'fakefs/safe'
  gem 'wisper-rspec'
end
