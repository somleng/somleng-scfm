require 'rails_helper'

RSpec.describe ContactFilter do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:factory) { :contact }
  let(:association_chain) { Contact }

  it_behaves_like "metadata_filter"

  describe "#resources" do
    let(:somali_msisdn) { generate(:somali_msisdn) }
    let(:contact) { create(factory, :msisdn => somali_msisdn) }

    def setup_scenario
      super
      contact
    end

    context "filtering by msisdn" do
      def filter_params
        super.merge(:msisdn => msisdn)
      end

      def assert_filter!
        expect(subject.resources).to match_array(asserted_results)
      end

      context "msisdn matches" do
        let(:msisdn) { somali_msisdn }
        let(:asserted_results) { [contact] }
        it { assert_filter! }
      end

      context "does not match" do
        let(:msisdn) { "wrong" }
        let(:asserted_results) { [] }
        it { assert_filter! }
      end
    end
  end
end
