require 'rails_helper'

RSpec.describe User do
  let(:factory) { :user }
  include_examples "has_metadata"

  describe "associations" do
    it { is_expected.to belong_to(:account) }
  end

  describe "validations" do
    def assert_validations!
      is_expected.to validate_presence_of(:email)
      is_expected.to validate_presence_of(:password)
      is_expected.to validate_confirmation_of(:password)
    end

    context "persisted" do
      subject { create(factory) }

      def assert_validations!
        super
        is_expected.to validate_uniqueness_of(:email).case_insensitive
      end

      it { assert_validations! }
    end

    it { assert_validations! }
  end

  describe "defaults" do
    subject { create(factory) }

    describe "#roles" do
      it { expect(subject.roles).to eq([:member]) }
    end
  end

  it '#is_admin?' do
    user = create(:user, roles: :admin)

    expect(user.is_admin?).to eq true
  end
end
