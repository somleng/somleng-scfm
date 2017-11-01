require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.around(:fakefs => true) do |example|
    FakeFS do
      FakeFS::FileSystem.clone("./app")
      FakeFS::FileSystem.clone("./spec")
      example.run
    end
  end
end
