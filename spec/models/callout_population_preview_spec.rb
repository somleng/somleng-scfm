require 'rails_helper'

RSpec.describe CalloutPopulationPreview do
  subject { described_class.new(:callout_population => callout_population) }

  describe "#contacts" do
    let(:contact_filter_params) {
      {
        :metadata => { "foo" => "bar" }
      }
    }

    let(:callout_population) {
      create(
        :callout_population,
        :contact_filter_params => contact_filter_params
      )
    }

    let(:contact_metadata) {
      {
        "foo" => "bar",
        "bar" => "baz"
      }
    }

    let(:contact) { create(:contact, :metadata => contact_metadata) }

    def setup_scenario
      super
      contact
      create(:contact)
    end

    it {
      expect(subject.contacts).to match_array([contact])
    }
  end
end
