require "rails_helper"

RSpec.describe PhoneCall do
  let(:factory) { :phone_call }

  include_examples "has_metadata"
  include_examples "has_call_flow_logic"

  describe "locking" do
    it "prevents stale phone calls from being updated" do
      phone_call1 = create(:phone_call)
      phone_call2 = PhoneCall.find(phone_call1.id)
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

    expect(PhoneCall.find_by(id: phone_call.id)).to eq(nil)
  end

  it "does not allow a queued call to be destroyed" do
    phone_call = create(:phone_call, :queued)

    phone_call.destroy

    expect(PhoneCall.find_by(id: phone_call.id)).to be_present
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

        phone_call.queue!

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

      it "transitions to completed from expired" do
        phone_call = create(:phone_call, :expired)
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

      it "transitions to expired" do
        phone_call = create(:phone_call, :remotely_queued, remotely_queued_at: 1.hour.ago)
        phone_call.remote_status = "queued"

        phone_call.complete!

        expect(phone_call.status).to eq("expired")
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

  describe "#remote_queue_response" do
    it { expect(subject.remote_queue_response).to eq({}) }
  end
end
