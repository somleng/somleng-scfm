require 'rails_helper'

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

  describe "#contact_filter_params" do
    it { expect(subject.contact_filter_params).to eq({}) }
  end

  describe "#contact_filter_params=(value)" do
    let(:value) { { "foo" => "bar" } }

    def setup_scenario
      super
      subject.contact_filter_params = value
    end

    it { expect(subject.contact_filter_params).to eq(value) }
  end

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
end
