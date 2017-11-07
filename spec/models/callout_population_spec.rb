require 'rails_helper'

RSpec.describe CalloutPopulation do

  let(:factory) { :callout_population }
  include_examples "has_metadata"

  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:callout)
    end

    it { assert_associations! }
  end

  describe "#contact_filter_params" do
    it { expect(subject.contact_filter_params).to eq({}) }
  end
end
