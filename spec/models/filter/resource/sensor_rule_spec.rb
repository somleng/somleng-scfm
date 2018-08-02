require "rails_helper"

RSpec.describe Filter::Resource::SensorRule do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :sensor_rule }
  let(:association_chain) { SensorRule }

  describe "#resources" do
    include_examples "timestamp_attribute_filter"

    it "can filter" do
      sensor_rule = create_sensor_rule(
        metadata: {
          "foo" => "bar",
          "bar" => "baz"
        }
      )

      filter = described_class.new(association_chain: SensorRule)

      filter.params = { sensor_id: sensor_rule.sensor_id }
      expect(filter.resources).to match_array([sensor_rule])

      filter.params = { sensor_id: "other" }
      expect(filter.resources).to be_empty

      filter.params = { metadata: { "bar" => "baz" } }
      expect(filter.resources).to match_array([sensor_rule])

      filter.params = { metadata: { "foo" => "wrong" } }
      expect(filter.resources).to be_empty
    end
  end

  def create_sensor_rule(metadata: {})
    sensor_rule = build(:sensor_rule)
    sensor_rule.metadata.merge!(metadata)
    sensor_rule.save!
    sensor_rule
  end
end
