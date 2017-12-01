require 'rails_helper'

RSpec.describe CalloutParticipation do
  let(:factory) { :callout_participation }
  include_examples "has_metadata"
  include_examples "has_call_flow_logic"

  include SomlengScfm::SpecHelpers::MsisdnExamples

  def msisdn_uniqueness_matcher
    super.scoped_to(:callout_id)
  end

  it_behaves_like "has_msisdn"

  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:callout)
      is_expected.to belong_to(:contact)
      is_expected.to belong_to(:callout_population)
      is_expected.to have_many(:phone_calls).dependent(:restrict_with_error)
      is_expected.to have_many(:remote_phone_call_events)
    end

    it { assert_associations! }
  end

  describe "validations" do
    context "persisted" do
      subject { create(factory) }

      def assert_validations!
        is_expected.to validate_uniqueness_of(:contact_id).scoped_to(:callout_id)
      end

      it { assert_validations! }
    end
  end

  describe "defaults" do
    let(:contact) { create(:contact) }
    subject { build(factory, :contact => contact) }

    def setup_scenario
      super
      subject.valid?
    end

    it { expect(subject.msisdn).to eq(contact.msisdn) }
  end

  describe "scopes" do
    def assert_scope!
      expect(results).to match_array(asserted_results)
    end

    context "relating to phone calls" do
      let(:callout) { create(:callout) }

      let(:callout_participation_with_no_calls) {
        create(
          factory, :callout => callout
        )
      }

      let(:callout_participation_last_attempt_failed) {
        create_callout_participation_last_attempt(
          :failed,
          :previous_attempt => :completed,
          :callout => callout
        )
      }

      let(:callout_participation_last_attempt_completed) {
        create_callout_participation_last_attempt(
          :completed,
          :previous_attempt => :failed,
          :callout => callout
        )
      }

      def setup_scenario
        super
        callout_participation_with_no_calls
        callout_participation_last_attempt_completed
        callout_participation_last_attempt_failed
      end

      def create_callout_participation_last_attempt(status, options = {})
        previous_attempt = options.delete(:previous_attempt)

        first_attempt = build(
          :phone_call,
          :status => previous_attempt,
          :callout_participation => nil
        ) if previous_attempt

        last_attempt = build(
          :phone_call,
          :status => status,
          :callout_participation => nil
        )

        create(
          factory, {
            :phone_calls => [first_attempt, last_attempt].compact
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
          let(:status) { [:failed, :completed] }
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
end
