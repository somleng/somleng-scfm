require "rails_helper"

RSpec.describe Filter::Resource::SensorEvent do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :sensor_event }
  let(:association_chain) { SensorEvent }

  describe "#resources" do
    include_examples "timestamp_attribute_filter"

    it "can filter" do
      sensor_rule = create(:sensor_rule)
      sensor_event = create(
        :sensor_event,
        sensor_rule: sensor_rule,
        sensor: sensor_rule.sensor,
        payload: {
          "foo" => "bar",
          "bar" => "baz"
        }
      )

      filter = described_class.new(
        association_chain: SensorEvent
      )

      filter.params = { sensor_id: sensor_event.sensor_id }
      expect(filter.resources).to match_array([sensor_event])

      filter.params = { sensor_id: "other" }
      expect(filter.resources).to be_empty

      filter.params = { sensor_rule_id: sensor_event.sensor_rule_id }
      expect(filter.resources).to match_array([sensor_event])

      filter.params = { sensor_rule_id: "other" }
      expect(filter.resources).to be_empty

      filter.params = {
        payload: {
          "bar" => "baz"
        }
      }
      expect(filter.resources).to match_array([sensor_event])

      filter.params = {
        payload: {
          "foo" => "wrong"
        }
      }
      expect(filter.resources).to be_empty
    end
  end
end
