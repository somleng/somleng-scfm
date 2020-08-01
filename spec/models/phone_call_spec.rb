require "rails_helper"

RSpec.describe PhoneCall do
  let(:factory) { :phone_call }

  include_examples "has_metadata"
  include_examples "has_call_flow_logic"

  describe "associations" do
    subject { build_stubbed(:phone_call, :inbound) }

    it { is_expected.to belong_to(:callout_participation).optional }
    it { is_expected.to belong_to(:contact).validate(true) }
    it { is_expected.to belong_to(:create_batch_operation).optional }
    it { is_expected.to belong_to(:queue_batch_operation).optional }
    it { is_expected.to belong_to(:queue_remote_fetch_batch_operation).optional }
    it { is_expected.to have_many(:remote_phone_call_events).dependent(:restrict_with_error) }
  end

  describe "locking" do
    it "prevents stale phone calls from being updated" do
      phone_call1 = create(:phone_call)
      phone_call2 = described_class.find(phone_call1.id)
      phone_call1.touch

      expect { phone_call2.touch }.to raise_error(ActiveRecord::StaleObjectError)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:msisdn) }

    it "allows multiple phone calls for the one callout participation" do
      account = create(:account)
      callout_participation = create_callout_participation(account: account)
      _existing_failed_phone_call = create_phone_call(
        account: account,
        callout_participation: callout_participation,
        status: PhoneCall::STATE_FAILED
      )

      phone_call = build(
        :phone_call,
        callout_participation: callout_participation,
        status: PhoneCall::STATE_CREATED
      )

      expect(phone_call).to be_valid
    end
  end

  it "sets defaults" do
    phone_call = create(:phone_call)

    expect(phone_call.msisdn).to be_present
  end

  it "sets defaults for an outbound call" do
    phone_call = build(:phone_call, :outbound)

    phone_call.valid?

    expect(phone_call.contact).to eq(phone_call.callout_participation.contact)
    expect(phone_call.msisdn).to eq(phone_call.callout_participation.msisdn)
  end

  it "can destroy a new phone call" do
    phone_call = create(:phone_call)

    phone_call.destroy

    expect(described_class.find_by_id(phone_call.id)).to eq(nil)
  end

  it "does not allow a queued call to be destroyed" do
    phone_call = create(:phone_call, :queued)

    phone_call.destroy

    expect(described_class.find_by_id(phone_call.id)).to be_present
    expect(phone_call.errors[:base].first).to eq(
      I18n.t!(
        "activerecord.errors.models.phone_call.attributes.base.restrict_destroy_status",
        status: PhoneCall::STATE_QUEUED
      )
    )
  end

  describe "state_machine" do
    describe "#queue!" do
      it "transitions to queued" do
        phone_call = create(:phone_call, :created)

        expect { phone_call.queue! }.to broadcast(:phone_call_queued)

        expect(phone_call).to be_queued
      end
    end

    describe "#queue_remote!" do
      it "updates the timestamp" do
        phone_call = create(:phone_call, :queued)

        phone_call.queue_remote!

        expect(phone_call.remotely_queued_at).to be_present
      end

      it "transitions to errored if there is no remote call id" do
        phone_call = create(:phone_call, :queued)

        phone_call.queue_remote!

        expect(phone_call).to be_errored
      end

      it "transitions to remotely_queued if there is a remote call id" do
        phone_call = create(:phone_call, :queued, remote_call_id: SecureRandom.uuid)

        phone_call.queue_remote!

        expect(phone_call).to be_remotely_queued
      end
    end

    describe "#complete!" do
      it "transitions to completed" do
        phone_call = create(:phone_call, :in_progress)
        phone_call.remote_status = "completed"

        phone_call.complete!

        expect(phone_call).to be_completed
      end

      it "transitions to failed" do
        phone_call = create(:phone_call, :in_progress)
        phone_call.remote_status = "failed"

        phone_call.complete!

        expect(phone_call).to be_failed
      end

      it "transitions to busy" do
        phone_call = create(:phone_call, :in_progress)
        phone_call.remote_status = "busy"

        phone_call.complete!

        expect(phone_call).to be_busy
      end

      it "transitions to in_progress from remotely_queued" do
        phone_call = create(:phone_call, :remotely_queued)
        phone_call.remote_status = "in-progress"

        phone_call.complete!

        expect(phone_call).to be_in_progress
      end

      it "transitions to in_progress from ringing" do
        phone_call = create(:phone_call, :remotely_queued)
        phone_call.remote_status = "ringing"

        phone_call.complete!

        expect(phone_call).to be_in_progress
      end

      it "transitions to not_answered" do
        phone_call = create(:phone_call, :in_progress)
        phone_call.remote_status = "no-answer"

        phone_call.complete!

        expect(phone_call).to be_not_answered
      end

      it "transitions to canceled" do
        phone_call = create(:phone_call, :remotely_queued)
        phone_call.remote_status = "canceled"

        phone_call.complete!

        expect(phone_call).to be_canceled
      end
    end
  end

  describe "#direction" do
    context "inbound" do
      it "returns inbound" do
        phone_call = build_stubbed(:phone_call, :inbound)
        expect(phone_call.direction).to eq(:inbound)
      end
    end

    context "outbound" do
      it "returns inbound" do
        phone_call = build_stubbed(:phone_call, :outbound)
        expect(phone_call.direction).to eq(:outbound)
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

    describe ".in_last_hours(hours, timestamp_column = :created_at)" do
      let(:remotely_queued_at) { nil }
      let(:created_at) { nil }

      def create_phone_call(*args)
        options = args.extract_options!
        create(factory, *args, factory_attributes.merge(options))
      end

      def factory_attributes
        {
          created_at: created_at
        }
      end

      let(:phone_call) { create_phone_call }
      let(:queued_phone_call) { create_phone_call(remotely_queued_at: remotely_queued_at) }

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
  end
end
