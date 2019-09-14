require "rails_helper"

RSpec.describe MetadataRequestSchema, type: :request_schema do
  it "validates the metadata" do
    expect(validate_schema(metadata: nil)).not_to have_valid_field(:metadata)
    expect(validate_schema({})).to have_valid_field(:metadata)
    expect(
      validate_schema(metadata: { "foo" => "bar" })
    ).to have_valid_field(:metadata)
  end

  it "validates the metadata merge mode" do
    expect(
      validate_schema(metadata_merge_mode: nil)
    ).not_to have_valid_field(:metadata_merge_mode)
    expect(
      validate_schema({})
    ).to have_valid_field(:metadata_merge_mode)
    expect(
      validate_schema(metadata_merge_mode: "foo")
    ).not_to have_valid_field(:metadata_merge_mode)
    expect(
      validate_schema(metadata_merge_mode: "replace")
    ).to have_valid_field(:metadata_merge_mode)
  end
end
