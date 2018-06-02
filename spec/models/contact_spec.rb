require "rails_helper"

RSpec.describe Contact do
  let(:factory) { :contact }

  include SomlengScfm::SpecHelpers::MsisdnExamples

  def msisdn_uniqueness_matcher
    super.scoped_to(:account_id)
  end

  it_behaves_like  "has_msisdn"

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
    def assert_validations!
      is_expected.to validate_presence_of(:commune_id).on(:dashboard)
    end

    it { assert_validations! }
  end

  describe "store_accessors" do
    it "store locations metadata" do
      contact = build(:contact,
        "province_id" => "01",
        "district_id" => "0102",
        "commune_id"  => "010203"
      )

      expect(contact.province_id).to eq "01"
      expect(contact.district_id).to eq "0102"
      expect(contact.commune_id).to  eq "010203"
    end
  end

  it "#commune" do
    location = Pumi::Commune.all.first
    contact = build(:contact, commune_id: location.id)
    expect(contact.commune).to eq location
  end
end
