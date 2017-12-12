require 'rails_helper'

RSpec.describe Account do
  let(:factory) { :account }
  include_examples "has_metadata"

  describe "associations" do
    def assert_associations!
      is_expected.to have_many(:users).dependent(:restrict_with_error)
      is_expected.to have_many(:contacts).dependent(:restrict_with_error)
      is_expected.to have_many(:callouts).dependent(:restrict_with_error)
      is_expected.to have_one(:access_token).dependent(:restrict_with_error)
    end

    it { assert_associations! }
  end

  describe "defaults" do
    subject { create(factory) }

    describe "#permissions" do
      it { expect(subject.permissions).to be_empty }
    end
  end
end
