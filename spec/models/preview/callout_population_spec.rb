require 'rails_helper'

RSpec.describe Preview::CalloutPopulation do
  let(:contact_filter_params) { {} }

  let(:callout_population) {
    create(
      :callout_population,
      :contact_filter_params => contact_filter_params
    )
  }

  subject { described_class.new(:previewable => callout_population) }

  describe "#contacts" do
    let(:contact_factory_params) { { :metadata => { "foo" => "bar", "bar" => "baz" } } }
    let(:contact) { create(:contact, contact_factory_params) }
    let(:contact_filter_params) { contact_factory_params.slice(:metadata) }

    def setup_scenario
      super
      contact
      create(:contact)
    end

    it { expect(subject.contacts).to match_array([contact]) }
  end
end
