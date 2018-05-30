require "rails_helper"

RSpec.describe BatchOperation::CalloutPopulation do
  let(:factory) { :callout_population }
  include_examples("batch_operation")

  describe "associations" do
    it { is_expected.to belong_to(:callout) }
    it { is_expected.to have_many(:callout_participations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:contacts) }
  end

  include_examples("hash_store_accessor", :contact_filter_params)

  describe "#run!" do
    it "populates the callout" do
      callout_population = create(:callout_population)
      contact = create(:contact, account: callout_population.account)
      _other_contact = create(:contact)

      callout_population.run!

      expect(callout_population.reload.contacts).to match_array([contact])
    end
  end

  describe "#contact_filter_metadata" do
    it "sets the contact filter metadata in the parameters attribute" do
      subject = described_class.new
      subject.contact_filter_metadata = { "gender" => "m" }

      expect(subject.contact_filter_metadata).to eq("gender" => "m")
      expect(subject.parameters).to eq(
        "contact_filter_params" => { "metadata" => { "gender" => "m" } }
      )
    end
  end
end
