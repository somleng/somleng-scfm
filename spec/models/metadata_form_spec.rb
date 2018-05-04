require "rails_helper"

RSpec.describe MetadataForm do
  describe "validations" do
    it "validates that attr_value is present" do
      metadata_form = described_class.new(attr_val: "Group 1")
      expect(metadata_form).to validate_presence_of(:attr_key)
    end
  end

  describe "#to_json" do
    it "should combine attr_key and attr_val to a hash" do
      metadata_form = described_class.new(
        attr_key: "address:city", attr_val: "Phnom Penh"
      )

      result = metadata_form.to_json

      expect(result).to eq(
        "address" => { "city" => "Phnom Penh" }
      )
    end
  end
end

RSpec.describe MetadataForm::Utils do
  describe "#flatten_hash" do
    it "flattens the hash" do
      utils =  MetadataForm::Utils.new
      hash = { "address" => { "city" => "Phnom Penh" } }

      expect(utils.flatten_hash(hash)).to eq("address:city" => "Phnom Penh")
    end
  end
end
