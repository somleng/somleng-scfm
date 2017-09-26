require 'rails_helper'

RSpec.describe PhoneNumber do
  let(:factory) { :phone_number }

  describe "associations" do
    def assert_associations!
      is_expected.to have_many(:phone_calls)
    end

    it { assert_associations! }
  end

  describe "validations" do
    context "new record" do
      def assert_validations!
        is_expected.to validate_presence_of(:msisdn)
        is_expected.to allow_value(generate(:somali_msisdn)).for(:msisdn)
        is_expected.not_to allow_value("252123456").for(:msisdn)
        is_expected.to allow_value("+252 66-(2)-345-678").for(:msisdn)
      end

      it { assert_validations! }
    end

    context "persisted" do
      subject { create(factory) }

      def assert_validations!
        is_expected.to validate_uniqueness_of(:msisdn).case_insensitive
      end

      it { assert_validations! }
    end
  end
end
