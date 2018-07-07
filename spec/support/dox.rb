require "dox"

RSpec.configure do |config|
  config.after(:each, :dox) do |example|
    example.metadata[:request] = request
    example.metadata[:response] = response
  end
end

Dox.configure do |config|
  config.headers_whitelist = %w[Authorization]
end

Dir[Rails.root.join("spec/docs/**/*.rb")].each { |f| require f }
