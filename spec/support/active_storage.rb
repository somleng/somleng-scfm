RSpec.configure do |config|
  config.before(:each, active_storage: true) do
    ActiveStorage::Current.url_options = { host: "example.com" }
  end
end
