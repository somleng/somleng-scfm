require "rails_helper"

RSpec.describe KeyValueField do
  describe "#to_json" do
    it "should combine the key and value to a hash" do
      key_value_field = described_class.new(
        key: "address:city", value: "Phnom Penh"
      )

      result = key_value_field.to_json

      expect(result).to eq(
        "address" => { "city" => "Phnom Penh" }
      )
    end
  end
end
