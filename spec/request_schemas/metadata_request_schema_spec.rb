require "rails_helper"

RSpec.describe MetadataRequestSchema, type: :request_schema do
  it "validates the metadata" do
    expect(validate_schema(input_params: { metadata: nil })).not_to have_valid_field(:metadata)
    expect(validate_schema(input_params: {})).to have_valid_field(:metadata)
    expect(
      validate_schema(input_params: { metadata: { "foo" => "bar" }})
    ).to have_valid_field(:metadata)
  end

  it "validates the metadata merge mode" do
    expect(
      validate_schema(input_params: { metadata_merge_mode: nil })
    ).not_to have_valid_field(:metadata_merge_mode)
    expect(
      validate_schema(input_params: {})
    ).to have_valid_field(:metadata_merge_mode)
    expect(
      validate_schema(input_params: { metadata_merge_mode: "foo"} )
    ).not_to have_valid_field(:metadata_merge_mode)
    expect(
      validate_schema(input_params: { metadata_merge_mode: "replace"} )
    ).to have_valid_field(:metadata_merge_mode)
  end

  def validate_schema(input_params:, options: {})
    MetadataRequestSchema.new(
      input_params:,
      options: options.reverse_merge(account: build_stubbed(:account))
    )
  end
end
