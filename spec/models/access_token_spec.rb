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
    let(:destroyer_traits) { {} }
    let(:destroyer) { create(:account, *destroyer_traits.keys) }
    let(:factory_attributes) { {:destroyer => destroyer, :created_by => creator} }
    subject { create(factory, factory_attributes) }

    def setup_scenario
      super
      subject.destroy
    end

    def assert_destroy!
      expect(described_class.find_by_id(subject.id)).to eq(nil)
    end

    context "no destroyer" do
      let(:destroyer) { nil }
      it { assert_destroy! }
    end

    context "destoyer is creator" do
      let(:destroyer) { creator }
      it { assert_destroy! }
    end

    context "destroyer is super admin" do
      let(:destroyer_traits) { super().merge(:super_admin => nil) }
      it { assert_destroy! }
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

  describe "#to_json" do
    let(:parsed_json) { JSON.parse(subject.to_json) }
    let(:asserted_keys) { ["id", "token", "created_at", "updated_at", "metadata"] }

    it {
      expect(parsed_json.keys).to match_array(asserted_keys)
    }
  end
end
