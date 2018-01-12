require 'rails_helper'

RSpec.describe AccessToken do
  let(:factory) { :access_token }
  include_examples "has_metadata"

  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:resource_owner)
      is_expected.to belong_to(:created_by)
    end

    it { assert_associations! }
  end

  describe "destroying" do
    let(:creator) { create(:account) }
    let(:destroyer) { create(:account) }
    let(:factory_attributes) { {:destroyer => destroyer, :created_by => creator} }
    subject { create(factory, factory_attributes) }

    def setup_scenario
      super
      subject.destroy
    end

    context "allowed to destroy" do
      let(:destroyer) { creator }

      it {
        expect(described_class.find_by_id(subject.id)).to eq(nil)
      }
    end

    context "not allowed to destroy" do
      it {
        expect(described_class.find_by_id(subject.id)).to be_present
        expect(subject.errors[:base]).not_to be_empty
        expect(
          subject.errors[:base].first
        ).to eq(
          I18n.t!(
            "activerecord.errors.models.access_token.attributes.base.restrict_destroy_status"
          )
        )
      }
    end
  end
end
