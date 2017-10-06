module SomlengScfm::SpecHelpers::MsisdnExamples
  def msisdn_uniqueness_matcher
    validate_uniqueness_of(:msisdn).case_insensitive
  end
end

RSpec.shared_examples_for "has_msisdn" do
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

      def assert_msisdn_uniqueness!
        is_expected.to msisdn_uniqueness_matcher
      end

      it { assert_msisdn_uniqueness! }
    end
  end
end
