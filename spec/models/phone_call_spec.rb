require 'rails_helper'

RSpec.describe PhoneCall do
  let(:factory) { :phone_call }
  include_examples "has_metadata"

  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:callout_participation)
      is_expected.to belong_to(:contact).validate(true)
      is_expected.to have_many(:remote_phone_call_events).dependent(:restrict_with_error)
    end

    it { assert_associations! }
  end

  describe "validations" do
    context "new record" do
      def assert_validations!
        is_expected.to validate_presence_of(:status)
      end

      context "for an inbound call" do
        subject { build(factory, :inbound) }
        it { is_expected.not_to validate_presence_of(:callout_participation) }
      end

      context "for an outbound call" do
        it { is_expected.to validate_presence_of(:callout_participation) }
      end

      it { assert_validations! }
    end

    context "persisted" do
      subject { create(factory) }

      def assert_validations!
        is_expected.to validate_uniqueness_of(:remote_call_id).case_insensitive
        is_expected.to validate_presence_of(:msisdn)
      end

      it { assert_validations! }
    end
  end

  describe "defaults" do
    subject { build(factory) }

    def setup_scenario
      super
      subject.valid?
    end

    def assert_defaults!
      expect(subject.contact).to be_present
      expect(subject.contact).to eq(subject.callout_participation.contact)
      expect(subject.msisdn).to be_present
      expect(subject.msisdn).to eq(subject.callout_participation.msisdn)
    end

    it { assert_defaults! }
  end

  describe "destroying" do
    let(:factory_attributes) { {} }
    subject { create(factory, factory_attributes) }

    def setup_scenario
      super
      subject.destroy
    end

    context "allowed to destroy" do
      it {
        expect(described_class.find_by_id(subject.id)).to eq(nil)
      }
    end

    context "not allowed to destroy" do
      let(:status) { described_class::STATE_QUEUED }
      let(:factory_attributes) { { :status => status } }

      it {
        expect(described_class.find_by_id(subject.id)).to be_present
        expect(subject.errors[:base]).not_to be_empty
        expect(
          subject.errors[:base].first
        ).to eq(
          I18n.t!(
            "activerecord.errors.models.phone_call.attributes.base.restrict_destroy_status",
            :status => status
          )
        )
      }
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

    describe "#queue!" do
      let(:current_status) { :created }
      let(:asserted_new_status) { :queued }
      let(:event) { :queue }

      it { assert_transitions! }

      it("should broadcast") {
        assert_broadcasted!(:phone_call_queued) { subject.queue! }
      }
    end

    describe "#queue_remote!" do
      let(:current_status) { :queued }
      let(:event) { :queue_remote }

      context "touching timestamp" do
        def setup_scenario
          super
          subject.queue_remote!
        end

        it { expect(subject.remotely_queued_at).to be_present }
      end

      context "by default" do
        let(:asserted_new_status) { :errored }
        it { assert_transitions! }
      end

      context "remote_call_id is present" do
        let(:asserted_new_status) { :remotely_queued }

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

    describe "#finish_fetching_status!" do
      let(:current_status) { :fetching_status }
      let(:asserted_new_status) { :queued }
      let(:event) { :finish_fetching_status }

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
    it { expect(subject.remote_response).to eq({}) }
  end

  describe "#remote_request_params" do
    it { expect(subject.remote_request_params).to eq({}) }
  end

  describe "#remote_queue_response" do
    it { expect(subject.remote_queue_response).to eq({}) }
  end

  describe "scopes" do
    def assert_scope!
      expect(results).to match_array(asserted_results)
    end

    describe ".remote_response_has_values(hash)" do
      include_examples "json_has_values" do
        let(:scope) { :remote_response_has_values }
        let(:json_column) { :remote_response }
      end
    end

    describe ".in_last_hours(hours, timestamp_column = :created_at)" do
      let(:remotely_queued_at) { nil }
      let(:created_at) { nil }

      def create_phone_call(*args)
        options = args.extract_options!
        create(factory, *args, factory_attributes.merge(options))
      end

      def factory_attributes
        {
          :created_at => created_at
        }
      end

      let(:phone_call) { create_phone_call }
      let(:queued_phone_call) { create_phone_call(:remotely_queued_at => remotely_queued_at) }

      let(:hours) { 1 }
      let(:timestamp_column) { nil }
      let(:args) { [hours, timestamp_column].compact }
      let(:results) { described_class.in_last_hours(*args) }

      def setup_scenario
        queued_phone_call
        phone_call
      end

      context "by default" do
        context "was created at more than specified hours ago" do
          let(:created_at) { hours.hours.ago }
          let(:asserted_results) { [] }
          it { assert_scope! }
        end

        context "was recently created" do
          let(:asserted_results) { [phone_call, queued_phone_call] }
          it { assert_scope! }
        end
      end

      context "passing timestamp_column = :remotely_queued_at" do
        let(:timestamp_column) { :remotely_queued_at }

        let(:asserted_results) { [queued_phone_call] }

        context "was recently queued" do
          let(:remotely_queued_at) { Time.now }
          it { assert_scope! }
        end

        context "was queued at more than specified hours ago" do
          let(:remotely_queued_at) { hours.hours.ago }
          let(:asserted_results) { [] }
          it { assert_scope! }
        end
      end
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

        def env
          super.merge(
            "PHONE_CALL_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS" => time_considered_recently_created_seconds
          )
        end

        it { assert_scope! }
      end
    end
  end
end
