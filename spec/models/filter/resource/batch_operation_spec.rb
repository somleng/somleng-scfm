require 'rails_helper'

RSpec.describe Filter::Resource::BatchOperation do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :callout_population }
  let(:association_chain) { BatchOperation::Base }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "timestamp_attribute_filter"

    context "filtering by parameters" do
      let(:filterable_attribute) { :parameters }
      include_examples "json_attribute_filter"
    end
  end
end
