require 'rails_helper'

RSpec.describe Filter::Resource::CalloutParticipation do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :callout_participation }
  let(:association_chain) { CalloutParticipation }

  it_behaves_like "metadata_attribute_filter"
  it_behaves_like "msisdn_attribute_filter"

  describe "#resources" do
    let(:factory_attributes) { {} }
    let(:callout_participation) { create(filterable_factory, factory_attributes) }
    let(:asserted_results) { [callout_participation] }

    def setup_scenario
      super
      create(filterable_factory)
      callout_participation
    end

    def assert_filter!
      expect(subject.resources).to match_array(asserted_results)
    end

    context "filtering by callout_id" do
      let(:callout) { create(:callout) }
      let(:factory_attributes) { { :callout => callout } }

      def filter_params
        super.merge(:callout_id => callout.id)
      end

      it { assert_filter! }
    end

    context "filtering by contact_id" do
      let(:contact) { create(:contact) }
      let(:factory_attributes) { { :contact => contact } }

      def filter_params
        super.merge(:contact_id => contact.id)
      end

      it { assert_filter! }
    end

    context "filtering by callout_population_id" do
      let(:callout_population) { create(:callout_population) }
      let(:factory_attributes) { { :callout_population => callout_population } }

      def filter_params
        super.merge(:callout_population_id => callout_population.id)
      end

      it { assert_filter! }
    end
  end
end
