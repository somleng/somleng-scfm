require "rails_helper"

RSpec.describe Preview::CalloutPopulation do
  describe "#contacts" do
    it "can filter the the contacts on the metadata" do
      account = create(:account)

      contact_metadata = {
        "foo" => "bar",
        "bar" => "baz"
      }

      contact = create(:contact, account: account, metadata: contact_metadata)
      _non_matching_contact = create(:contact, account: account)
      other_contact = create(:contact, metadata: contact_metadata)

      callout_population = create(
        :callout_population,
        contact_filter_params: {
          metadata: contact_metadata
        }
      )

      preview = described_class.new(
        previewable: callout_population
      )

      expect(preview.contacts(scope: Contact)).to match_array([contact, other_contact])
      expect(preview.contacts(scope: account.contacts)).to match_array([contact])
    end
  end
end
