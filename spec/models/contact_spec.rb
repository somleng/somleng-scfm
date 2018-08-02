require "rails_helper"

RSpec.describe Contact do
  let(:factory) { :contact }

  include SomlengScfm::SpecHelpers::MsisdnExamples

  def msisdn_uniqueness_matcher
    super.scoped_to(:account_id)
  end

  it_behaves_like "has_msisdn"

  describe "associations" do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to have_many(:callout_participations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:callouts) }
    it { is_expected.to have_many(:phone_calls).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:remote_phone_call_events) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:call_flow_logic).to(:account) }
  end

  describe "validations" do
    it "normalizes the commune ids" do
      contact = build_stubbed(:contact)
      contact.metadata["commune_ids"] = %w[120101 120102]

      contact.valid?

      expect(contact.metadata.fetch("commune_ids")).to match_array(%w[120101 120102])

      contact.metadata["commune_ids"] = "120101  120102"

      contact.valid?

      expect(contact.metadata.fetch("commune_ids")).to match_array(%w[120101 120102])
    end
  end
end
