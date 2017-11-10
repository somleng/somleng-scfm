require 'rails_helper'

RSpec.describe Filter::Resource::CalloutPopulation do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :callout_population }
  let(:association_chain) { CalloutPopulation }

  it_behaves_like "metadata_attribute_filter"

  describe "#resources" do
    let(:persisted_contact_filter_params) {
      {
        "foo" => "bar",
        "bar" => "baz"
      }
    }

    let(:callout_population) {
      create(
        filterable_factory,
        :contact_filter_params => persisted_contact_filter_params
      )
    }

    def setup_scenario
      super
      callout_population
    end

    context "filtering by contact_filter_params" do
      def filter_params
        super.merge(:contact_filter_params => contact_filter_params)
      end

      def assert_filter!
        expect(subject.resources).to match_array(asserted_results)
      end

      context "contact_filter_params match" do
        let(:contact_filter_params) { { "foo" => "bar" } }
        let(:asserted_results) { [callout_population] }
        it { assert_filter! }
      end

      context "contact_filter_params do not match" do
        let(:contact_filter_params) { { "foo" => "baz" } }
        let(:asserted_results) { [] }
        it { assert_filter! }
      end
    end
  end
end
