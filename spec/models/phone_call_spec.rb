require 'rails_helper'

RSpec.describe PhoneCall do
  let(:factory) { :phone_call }
  include_examples "has_metadata"

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

  describe "optimistic locking" do
    subject { create(factory) }

    def assert_optimistic_locking!
      process1 = described_class.find(subject.id)
      process2 = described_class.find(subject.id)
      process1.metadata["foo"] = "bar"
      process1.save!
      process2.metadata["foo"] = "bar"
      expect { process2.save! }.to raise_error(ActiveRecord::StaleObjectError)
    end

    it { assert_optimistic_locking! }
  end

  describe "state_machine" do
    subject { create(factory, factory_attributes) }

    def factory_attributes
      {:status => current_status}
    end

    def assert_transitions!
      is_expected.to transition_from(current_status).to(asserted_new_status).on_event(event)
    end

    describe "#schedule!" do
      let(:current_status) { :created }
      let(:asserted_new_status) { :scheduling }
      let(:event) { :schedule }

      it { assert_transitions! }
    end

    describe "#queue!" do
      let(:current_status) { :scheduling }
      let(:event) { :queue }

      context "by default" do
        let(:asserted_new_status) { :errored }
        it { assert_transitions! }
      end

      context "remote_call_id is present" do
        let(:asserted_new_status) { :queued }

        def factory_attributes
          super.merge(:remote_call_id => "1234")
        end

        it { assert_transitions! }
      end
    end

    describe "#fetch_status!" do
      let(:current_status) { :queued }
      let(:asserted_new_status) { :fetching_status }
      let(:event) { :fetch_status }

      it { assert_transitions! }
    end

    describe "#complete!" do
      let(:event) { :complete }
      let(:current_status) { :fetching_status }

      def factory_attributes
        super.merge(:remote_status => remote_status)
      end

      ["in-progress", "ringing"].each do |remote_status|
        context "remote_status: '#{remote_status}'" do
          let(:remote_status) { remote_status }
          let(:asserted_new_status) { :in_progress }

          it { assert_transitions! }
        end
      end

      {
        "busy" => :busy,
        "failed" => :failed,
        "no-answer" => :not_answered,
        "canceled" => :canceled,
        "completed" => :completed
      }.each do |remote_status, asserted_new_status|
        context "remote_status: '#{remote_status}'" do
          let(:remote_status) { remote_status }
          let(:asserted_new_status) { asserted_new_status }
          it { assert_transitions! }
        end
      end
    end
  end

  describe "#remote_response" do
    def assert_remote_response!
      expect(subject.remote_response).to eq({})
    end

    it { assert_remote_response! }
  end

  describe "scopes" do
    before do
      setup_scenario
    end

    def assert_scope!
      expect(results).to match_array(asserted_results)
    end

    describe ".from_running_callout" do
      let(:running_callout) { create(:callout, :status => :running) }
      let(:phone_call) { create(factory, :callout => running_callout) }
      let(:results) { described_class.from_running_callout }
      let(:asserted_results) { [phone_call] }

      def setup_scenario
        create(factory)
        phone_call
      end

      it { assert_scope! }
    end

    describe ".with_remote_call_id" do
      let(:phone_call) { create(factory, :remote_call_id => "foo") }
      let(:results) { described_class.with_remote_call_id }
      let(:asserted_results) { [phone_call] }

      def setup_scenario
        create(factory)
        phone_call
      end

      it { assert_scope! }
    end

    describe ".not_recently_created" do
      let(:results) { described_class.not_recently_created }

      let(:phone_call) {
        create(
          factory,
          :created_at => time_considered_recently_created_seconds.to_i.seconds.ago
        )
      }

      let(:asserted_results) { [phone_call] }

      def setup_scenario
        create(factory)
        phone_call
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
end
