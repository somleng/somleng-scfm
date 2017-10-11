require 'rails_helper'

RSpec.describe Contact do
  let(:factory) { :contact }

  include SomlengScfm::SpecHelpers::MsisdnExamples

  include_examples "has_metadata"
  it_behaves_like "has_msisdn"

  describe "associations" do
    def assert_associations!
      is_expected.to have_many(:callout_participations)
      is_expected.to have_many(:callouts)
      is_expected.to have_many(:phone_calls)
    end

    it { assert_associations! }
  end
end
