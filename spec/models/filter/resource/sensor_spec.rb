require "rails_helper"

RSpec.describe Filter::Resource::Sensor do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :sensor }
  let(:association_chain) { Sensor }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "timestamp_attribute_filter"
  end
end
