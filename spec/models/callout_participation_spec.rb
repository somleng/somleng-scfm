require "rails_helper"

RSpec.describe CalloutParticipation do
  let(:factory) { :callout_participation }

  include_examples "has_metadata"
  include_examples "has_call_flow_logic"

  describe "associations" do
    it { is_expected.to have_many(:phone_calls).dependent(:restrict_with_error) }
    it { is_expected.to belong_to(:callout_population).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:msisdn) }
    it { is_expected.to allow_value(generate(:somali_msisdn)).for(:msisdn) }
    it { is_expected.not_to allow_value("252123456").for(:msisdn) }
    it { is_expected.to allow_value("+252 66-(2)-345-678").for(:msisdn) }
    it { expect(create(:callout_participation)).to validate_uniqueness_of(:contact_id).scoped_to(:callout_id) }
  end

  it "sets defaults" do
    contact = create(:contact)
    callout_participation = build(:callout_participation, contact: contact)

    callout_participation.valid?

    expect(callout_participation.msisdn).to eq(contact.msisdn)
  end

  describe "scopes" do
    def assert_scope!
      expect(results).to match_array(asserted_results)
    end

    context "relating to phone calls" do
      let(:callout) { create(:callout) }

      let(:callout_participation_with_no_calls) do
        create(
          factory, callout: callout
        )
      end

      let(:callout_participation_last_attempt_failed) do
        create_callout_participation_last_attempt(
          :failed,
          previous_attempt: :completed,
          callout: callout
        )
      end

      let(:callout_participation_last_attempt_completed) do
        create_callout_participation_last_attempt(
          :completed,
          previous_attempt: :failed,
          callout: callout
        )
      end

      def setup_scenario
        super
        callout_participation_with_no_calls
        callout_participation_last_attempt_completed
        callout_participation_last_attempt_failed
      end

      def create_callout_participation_last_attempt(status, options = {})
        previous_attempt = options.delete(:previous_attempt)

        if previous_attempt
          first_attempt = build(
            :phone_call,
            status: previous_attempt,
            callout_participation: nil
          )
        end

        last_attempt = build(
          :phone_call,
          status: status,
          callout_participation: nil
        )

        create(
          factory, {
            phone_calls: [first_attempt, last_attempt].compact
          }.merge(options)
        )
      end

      describe ".last_phone_call_attempt(status)" do
        let(:results) { described_class.last_phone_call_attempt(status) }

        context "failed" do
          let(:status) { :failed }
          let(:asserted_results) { [callout_participation_last_attempt_failed] }

          it { assert_scope! }
        end

        context "completed" do
          let(:status) { :completed }
          let(:asserted_results) { [callout_participation_last_attempt_completed] }

          it { assert_scope! }
        end

        context "failed or completed" do
          let(:status) { %i[failed completed] }
          let(:asserted_results) { [callout_participation_last_attempt_failed, callout_participation_last_attempt_completed] }

          it { assert_scope! }
        end
      end

      describe ".no_phone_calls_or_last_attempt(status)" do
        let(:status) { :failed }
        let(:results) { described_class.no_phone_calls_or_last_attempt(status) }
        let(:asserted_results) { [callout_participation_with_no_calls, callout_participation_last_attempt_failed] }

        it { assert_scope! }
      end

      describe ".no_phone_calls" do
        let(:results) { described_class.no_phone_calls }
        let(:asserted_results) { [callout_participation_with_no_calls] }

        it { assert_scope! }
      end
    end
  end

  describe ".having_max_phone_calls_count" do
    it "returns only callout participations that have less than or equal to count" do
      max_phone_calls = 3
      empty_phone_calls_callout_participation = create(:callout_participation)
      less_than_max_phone_calls_callout_participation = create(:callout_participation)
      more_than_max_phone_calls_callout_participation = create(:callout_participation)
      create(
        :phone_call,
        callout_participation: less_than_max_phone_calls_callout_participation,
        status: PhoneCall::STATE_FAILED
      )
      create_list(
        :phone_call,
        max_phone_calls,
        callout_participation: more_than_max_phone_calls_callout_participation,
        status: PhoneCall::STATE_FAILED
      )

      results = described_class.having_max_phone_calls_count(max_phone_calls)

      expect(results).to match_array([
                                       empty_phone_calls_callout_participation,
                                       less_than_max_phone_calls_callout_participation
                                     ])
    end
  end
end
