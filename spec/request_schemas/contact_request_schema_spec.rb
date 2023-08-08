require "rails_helper"

RSpec.describe ContactRequestSchema, type: :request_schema do
  it "validates the msisdn" do
    contact = create(:contact)

    expect(validate_schema(input_params: {})).not_to have_valid_field(:msisdn)
    expect(validate_schema(input_params: { msisdn: nil })).not_to have_valid_field(:msisdn)
    expect(
      validate_schema(input_params: { msisdn: "+855 97 2345 6789" })
    ).not_to have_valid_field(:msisdn)

    expect(
      validate_schema(input_params: { msisdn: "+855 97 2345 678" })
    ).to have_valid_field(:msisdn)

    expect(
      validate_schema(
        input_params: { msisdn: contact.msisdn },
        options: { account: contact.account }
      )
    ).not_to have_valid_field(:msisdn)

    expect(
      validate_schema(
        input_params: { msisdn: contact.msisdn },
        options: { resource: contact, account: contact.account }
      )
    ).to have_valid_field(:msisdn)

    expect(
      validate_schema(
        input_params: {},
        options: { resource: contact, account: contact.account }
      )
    ).to have_valid_field(:msisdn)
  end

  it "validates the metadata fields attributes" do
    expect(
      validate_schema(input_params: { metadata_fields_attributes: nil })
    ).not_to have_valid_field(:metadata_fields_attributes)
    expect(
      validate_schema(input_params: {})
    ).to have_valid_field(:metadata_fields_attributes)
    expect(
      validate_schema(input_params: { metadata_fields_attributes: "foo" })
    ).not_to have_valid_field(:metadata_fields_attributes)
    expect(
      validate_schema(input_params: { metadata_fields_attributes: { "foo" => "bar" } })
    ).to have_valid_field(:metadata_fields_attributes)
  end

  it "handles postprocessing" do
    expect(
      validate_schema(input_params: { msisdn: "(855) 97 2345 678" }).output.fetch(:msisdn)
    ).to eq("+855972345678")
  end

  def validate_schema(input_params:, options: {})
    ContactRequestSchema.new(
      input_params:,
      options: options.reverse_merge(account: build_stubbed(:account))
    )
  end
end
