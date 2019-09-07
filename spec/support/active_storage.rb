RSpec.configure do |config|
  config.before do
    ActiveStorage::Current.host = "https://www.example.com"
  end
end
