require "strip_attributes/matchers"

RSpec.configure do |config|
  config.include(StripAttributes::Matchers, type: :model)
end
