require 'rails_helper'

RSpec.describe Filter::Resource::CalloutPopulation do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :callout_population }
  let(:association_chain) { CalloutPopulation }

  describe "#resources" do
    include_examples "metadata_attribute_filter"

    context "filtering by contact_filter_params" do
      let(:filterable_attribute) { :contact_filter_params }
      include_examples "json_attribute_filter"
    end
  end
end
