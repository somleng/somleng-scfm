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
      is_expected.to transition_from(:new).to(:queued).on_event(:queue)
    end

    it { assert_transitions! }
  end

  describe "#remote_response" do
    def assert_remote_response!
      expect(subject.remote_response).to eq({})
    end

    it { assert_remote_response! }
  end

  describe ".not_recent" do
    let(:not_recent) {
      create(
        factory,
        :created_at => described_class::DEFAULT_TIME_CONSIDERED_RECENT_SECONDS.seconds.ago
      )
    }

    def setup_scenario
      create(factory)
      not_recent
    end

    before do
      setup_scenario
    end

    it { expect(described_class.not_recent).to match_array([not_recent]) }
  end
end
