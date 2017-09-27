require 'rails_helper'

RSpec.describe PhoneCall do
  let(:factory) { :phone_call }

  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:phone_number)
    end

    it { assert_associations! }
  end

  describe "validations" do
    context "new record" do
      def assert_validations!
        is_expected.to validate_presence_of(:status)
      end

      it { assert_validations! }
    end

    context "persisted" do
      subject { create(factory) }

      def assert_validations!
        is_expected.to validate_uniqueness_of(:remote_call_id).case_insensitive
      end

      it { assert_validations! }
    end
  end

  describe "state_machine" do
    def assert_transitions!
      is_expected.to transition_from(:created).to(:scheduling).on_event(:schedule)
      is_expected.to transition_from(:scheduling).to(:errored).on_event(:queue)
    end

    context "remote_call_id is present" do
      subject { build(factory, :remote_call_id => "1234") }

      it { is_expected.to transition_from(:scheduling).to(:queued).on_event(:queue) }
    end

    it { assert_transitions! }
  end

  describe "#remote_response" do
    def assert_remote_response!
      expect(subject.remote_response).to eq({})
    end

    it { assert_remote_response! }
  end

  describe ".not_recently_created" do
    let(:results) { described_class.not_recently_created }

    let(:not_recent) {
      create(
        factory,
        :created_at => time_considered_recently_created_seconds.to_i.seconds.ago
      )
    }

    def setup_scenario
      create(factory)
      not_recent
    end

    before do
      setup_scenario
    end

    def assert_scope!
      expect(results).to match_array([not_recent])
    end

    context "using defaults" do
      let(:time_considered_recently_created_seconds) {
        described_class::DEFAULT_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS
      }
      it { assert_scope! }
    end

    context "setting PHONE_CALL_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS" do
      let(:time_considered_recently_created_seconds) { "120" }

      def setup_scenario
        stub_env(
          "PHONE_CALL_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS" => time_considered_recently_created_seconds
        )
        super
      end

      it { assert_scope! }
    end
  end
end
