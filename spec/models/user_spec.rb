require "rails_helper"

RSpec.describe User do
  let(:factory) { :user }
  include_examples "has_metadata"

  describe "associations" do
    it { is_expected.to belong_to(:account) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_confirmation_of(:password) }
    it { is_expected.to validate_inclusion_of(:locale).in_array(%w[en km]) }

    context "persisted" do
      subject { create(:user) }
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    end

    it "cleans up the user's province ids" do
      user = build_stubbed(:user)
      user.province_ids = ["", "01"]

      user.valid?

      expect(user.province_ids).to match_array(["01"])

      user.province_ids = [""]

      user.valid?

      expect(user.metadata).to eq({})
    end
  end

  describe "defaults" do
    it { expect(User.new.roles).to eq([:member]) }
  end

  it "#admin?" do
    user = build_stubbed(:user, roles: :admin)

    expect(user.admin?).to eq true
  end
end
