RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

module FactoryBot
  module Syntax
    module Methods
      def fixture_file(file_name)
        file_path = ActiveSupport::TestCase.fixture_path + "/files/#{file_name}"
        {
          io: File.open(file_path),
          filename: file_name
        }
      end
    end
  end
end
