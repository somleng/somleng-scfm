require 'rails_helper'

RSpec.describe Filter::Resource::Contact do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :contact }
  let(:association_chain) { Contact }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "msisdn_attribute_filter"
    include_examples "timestamp_attribute_filter"
  end

  describe "filtering" do
    it "finds contacts that match locations filter" do
      matched_contact1 = create(:contact, metadata: { commune_ids: %w[040202 030202] })
      matched_contact2 = create(:contact, metadata: { commune_ids: ["010202"] })
      _unmatched_contact = create(:contact, metadata: { commune_ids: ["040201"] })

      results = described_class.new(
        { association_chain: Contact.all },
        has_locations_in: %w[010202 040202]
      ).resources

      expect(results).to match_array([matched_contact1, matched_contact2])
    end
  end
end
