require "rails_helper"

RSpec.describe ContactRequestSchema, type: :request_schema do
  it "validates the msisdn" do
    contact = create(:contact)

    expect(validate_request_schema({})).not_to have_valid_field(:msisdn)
    expect(validate_request_schema(msisdn: nil)).not_to have_valid_field(:msisdn)
    expect(
      validate_request_schema(msisdn: "+855 97 2345 6789")
    ).not_to have_valid_field(:msisdn)
    expect(
      validate_request_schema(msisdn: "+855 97 2345 678")
    ).to have_valid_field(:msisdn)
    expect(
      validate_request_schema(msisdn: contact.msisdn, account: contact.account)
    ).not_to have_valid_field(:msisdn)
    expect(
      validate_request_schema(
        msisdn: contact.msisdn, contact: contact, account: contact.account
      )
    ).to have_valid_field(:msisdn)
    expect(validate_request_schema(contact: contact)).to have_valid_field(:msisdn)
  end

  it "validates the metadata fields attributes" do
    expect(
      validate_request_schema(metadata_fields_attributes: nil)
    ).not_to have_valid_field(:metadata_fields_attributes)
    expect(
      validate_request_schema({})
    ).to have_valid_field(:metadata_fields_attributes)
    expect(
      validate_request_schema(metadata_fields_attributes: "foo")
    ).not_to have_valid_field(:metadata_fields_attributes)
    expect(
      validate_request_schema(metadata_fields_attributes: { "foo" => "bar" })
    ).to have_valid_field(:metadata_fields_attributes)
  end

  it "handles postprocessing" do
    expect(
      validate_request_schema(msisdn: "(855) 97 2345 678").output.fetch(:msisdn)
    ).to eq("+855972345678")
  end

  def validate_request_schema(options)
    contact = options.delete(:contact)
    account = options.delete(:account) || contact&.account

    validate_schema(
      options,
      schema_options: {
        resource: contact,
        account: account
      }.compact
    )
  end
end
