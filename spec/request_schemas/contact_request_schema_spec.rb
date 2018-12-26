require "rails_helper"

RSpec.describe ContactRequestSchema, type: :request_schema do
  let(:account) { create(:account) }

  it { expect(validate_schema(msisdn: nil)).not_to have_valid_field(:msisdn) }
  it { expect(validate_schema({}, with: { action: "update" })).to have_valid_field(:msisdn) }
  it { expect(validate_schema(msisdn: "+855 97 2345 6789")).not_to have_valid_field(:msisdn) }
  it {
    expect(
      validate_schema(
        { msisdn: create(:contact, account: account).msisdn }, with: { account: account, resource: Contact.new }
      )
    ).not_to have_valid_field(:msisdn)
  }
  it {
    contact = create(:contact, account: account)
    expect(
      validate_schema(
        { msisdn: contact.msisdn }, with: { account: account, resource: contact }
      )
    ).to have_valid_field(:msisdn)
  }
  it {
    expect(
      validate_schema(
        { msisdn: "+855 97 2345 678" }, with: { resource: Contact.new, account: account }
      )
    ).to have_valid_field(:msisdn)
  }

  it { expect(validate_schema(metadata: nil)).not_to have_valid_field(:metadata) }
  it { expect(validate_schema).to have_valid_field(:metadata) }
  it { expect(validate_schema(metadata: { "foo" => "bar" })).to have_valid_field(:metadata) }

  it { expect(validate_schema(metadata_merge_mode: nil)).not_to have_valid_field(:metadata_merge_mode) }
  it { expect(validate_schema(metadata_merge_mode: "foo")).not_to have_valid_field(:metadata_merge_mode) }
  it { expect(validate_schema).to have_valid_field(:metadata_merge_mode) }
  it { expect(validate_schema(metadata_merge_mode: "replace")).to have_valid_field(:metadata_merge_mode) }

  it { expect(validate_schema(metadata_fields_attributes: nil)).not_to have_valid_field(:metadata_fields_attributes) }
  it { expect(validate_schema(metadata_fields_attributes: "foo")).not_to have_valid_field(:metadata_fields_attributes) }
  it { expect(validate_schema).to have_valid_field(:metadata_fields_attributes) }
  it { expect(validate_schema(metadata_fields_attributes: { "foo" => "bar" })).to have_valid_field(:metadata_fields_attributes) }
end
