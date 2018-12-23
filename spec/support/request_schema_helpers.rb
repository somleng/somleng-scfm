module RequestSchemaHelpers
  def validate_schema(params = {}, options = {})
    described_class.with(options.fetch(:with) { {} }).call(params)
  end
end

RSpec.configure do |config|
  config.include RequestSchemaHelpers, type: :request_schema
end
