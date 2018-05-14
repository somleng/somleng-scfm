require "rails_helper"

RSpec.describe BatchOperation::CalloutPopulation do
  let(:factory) { :callout_population }
  include_examples("batch_operation")

  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:callout)
      is_expected.to have_many(:callout_participations).dependent(:restrict_with_error)
      is_expected.to have_many(:contacts)
    end

    it { assert_associations! }
  end

  include_examples("hash_store_accessor", :contact_filter_params)

  describe "#run!" do
    let(:contact) { create(:contact) }
    subject { create(factory) }

    def setup_scenario
      super
      contact
      subject.run!
    end

    it {
      expect(subject.reload.contacts).to eq([contact])
    }
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
