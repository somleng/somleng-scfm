require 'rails_helper'

RSpec.describe Contact do
  let(:factory) { :contact }

  include SomlengScfm::SpecHelpers::MsisdnExamples

  def msisdn_uniqueness_matcher
    super.scoped_to(:account_id)
  end

  include_examples "has_metadata"
  it_behaves_like "has_msisdn"

  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:account)
      is_expected.to have_many(:callout_participations).dependent(:restrict_with_error)
      is_expected.to have_many(:callouts)
      is_expected.to have_many(:phone_calls).dependent(:restrict_with_error)
      is_expected.to have_many(:remote_phone_call_events)
    end

    it { assert_associations! }
  end

  describe 'scope' do
    it 'search' do
      contact = create(:contact, msisdn: 252662345678)

      expect(Contact.search('66')).to eq [contact]
    end
  end
end
