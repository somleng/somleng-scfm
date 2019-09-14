module RequestSchemaHelpers
  def validate_schema(input_params, schema_options: {})
    schema_options.reverse_merge!(
      account: build_stubbed(:account)
    )

    described_class.new(
      input_params: input_params,
      options: schema_options
    )
  end
end

RSpec.configure do |config|
  config.include RequestSchemaHelpers, type: :request_schema
end
