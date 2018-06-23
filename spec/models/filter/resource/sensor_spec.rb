require "rails_helper"

RSpec.describe Filter::Resource::Sensor do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :sensor }
  let(:association_chain) { Sensor }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "timestamp_attribute_filter"

    it "can filter by external_id" do
      sensor = create(:sensor)
      filter = described_class.new(
        association_chain: Sensor
      )
      filter.params = { external_id: sensor.external_id }

      expect(filter.resources).to match_array([sensor])

      filter.params = { external_id: generate(:sensor_external_id) }

      expect(filter.resources).to match_array([])
    end
  end
end
