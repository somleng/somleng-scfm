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
    it { is_expected.to validate_presence_of(:commune_id).on(:dashboard) }

    it "validates the commune" do
      contact = build(:contact)
      contact.commune_id = nil

      expect(contact).to be_valid

      contact.commune_id = "wrong"

      expect(contact).not_to be_valid
      expect(contact.errors[:commune_id]).to be_present

      contact.commune_id = "120101"
      expect(contact).to be_valid
    end

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

  describe "store_accessors" do
    it "store locations metadata" do
      contact = build(
        :contact,
        "province_id" => "01",
        "district_id" => "0102",
        "commune_id"  => "010203"
      )

      expect(contact.province_id).to eq("01")
      expect(contact.district_id).to eq("0102")
      expect(contact.commune_id).to eq("010203")
    end
  end

  describe "#commune" do
    it "returns the commune from the commune_id" do
      contact = build_stubbed(:contact, commune_id: "120101")

      expect(contact.commune.id).to eq("120101")
    end
  end
end
