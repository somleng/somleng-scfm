RSpec.describe KeyValueFieldsBuilder do
  describe "#from_attributes" do
    it "builds a collection of KeyValueField instances" do
      builder = described_class.new
      attributes = {
        "0" => {
          "key" => "address:city", "value" => "Phnom Penh"
        },
        "1" => {
          "key" => "address:country", "value" => "Cambodia"
        }
      }

      assert_collection!(builder.from_attributes(attributes))
    end
  end

  describe "#from_nested_hash" do
    it "builds a collection of key value fields" do
      builder =  described_class.new
      hash = { "address" => { "city" => "Phnom Penh", "country" => "Cambodia" } }

      assert_collection!(builder.from_nested_hash(hash))
    end
  end

  describe "#to_h" do
    it "returns a nested hash" do
      builder = described_class.new
      key_value_fields = [
        KeyValueField.new(key: "address:city", value: "Phnom Penh"),
        KeyValueField.new(key: "address:country", value: "Cambodia")
      ]

      expect(builder.to_h(key_value_fields)).to eq(
        "address" => { "city" => "Phnom Penh", "country" => "Cambodia" }
      )
    end
  end

  def assert_collection!(collection)
    expect(collection.size).to eq(2)
    expect(collection[0].key).to eq("address:city")
    expect(collection[0].value).to eq("Phnom Penh")
    expect(collection[1].key).to eq("address:country")
    expect(collection[1].value).to eq("Cambodia")
  end
end
