require "rails_helper"

RSpec.describe CallFlowLogic::Base do
  describe ".registered" do
    it "returns registered call flow logic" do
      call_flow_logic = [
        CallFlowLogic::HelloWorld,
        CallFlowLogic::PlayMessage
      ].map(&:to_s)

      registered_call_flow_logic = described_class.registered

      expect(registered_call_flow_logic).to include(*call_flow_logic)
      expect(registered_call_flow_logic).not_to include(CallFlowLogic::Base.to_s)
    end
  end

  describe "#run!" do
    it "tries to complete the phone call" do
      phone_call, event = create_phone_call_with_event(status: :remotely_queued, remote_status: "in-progress")
      call_flow_logic = described_class.new(event: event)

      call_flow_logic.run!

      expect(phone_call.reload.status).to eq("in_progress")
    end

    it "retries outbound calls" do
      travel_to(Time.current) do
        account = create(:account, settings: { max_phone_calls_for_callout_participation: 3 })
        callout_participation = create_callout_participation(account: account)
        phone_call, event = create_phone_call_with_event(
          callout: callout_participation.callout,
          callout_participation: callout_participation,
          status: :remotely_queued,
          remote_status: "failed"
        )
        call_flow_logic = described_class.new(event: event)

        call_flow_logic.run!

        expect(RetryPhoneCallJob).to have_been_enqueued.at(15.minutes.from_now).with(phone_call)

        perform_enqueued_jobs

        new_phone_call = callout_participation.phone_calls.last
        expect(callout_participation.phone_calls.count).to eq(2)
        expect(new_phone_call).to have_attributes(
          status: "created",
          callout_participation: callout_participation,
          callout: callout_participation.callout,
          contact: callout_participation.contact
        )
      end
    end

    it "does not retry calls if maximum number of calls is reached" do
      account = create(:account, settings: { max_phone_calls_for_callout_participation: 1 })
      callout_participation = create_callout_participation(account: account)
      _, event = create_phone_call_with_event(
        callout_participation: callout_participation,
        status: "remotely_queued",
        remote_status: "failed"
      )
      call_flow_logic = described_class.new(event: event)

      call_flow_logic.run!

      expect(RetryPhoneCallJob).not_to have_been_enqueued
    end

    it "does not retry calls past the global max retries limit" do
      stub_const("CallFlowLogic::Base::MAX_RETRIES", 1)
      account = create(:account, settings: { max_phone_calls_for_callout_participation: 100 })

      callout_participation = create_callout_participation(account: account)
      _, event = create_phone_call_with_event(
        callout_participation: callout_participation,
        status: "remotely_queued",
        remote_status: "failed"
      )
      call_flow_logic = described_class.new(event: event)

      call_flow_logic.run!

      expect(RetryPhoneCallJob).not_to have_been_enqueued
    end

    it "retries ActiveRecord::StaleObjectError" do
      phone_call, event = create_phone_call_with_event(status: :remotely_queued, remote_status: "in-progress")
      call_flow_logic = described_class.new(event: event)
      PhoneCall.find(phone_call.id).touch

      call_flow_logic.run!

      expect(phone_call.reload.status).to eq("in_progress")
    end
  end

  def create_phone_call_with_event(status: :in_progress, remote_status: "in-progress", **phone_call_attributes)
    phone_call = create(
      :phone_call,
      status: status,
      remote_status: remote_status,
      **phone_call_attributes
    )
    event = create(:remote_phone_call_event, phone_call: phone_call)
    [phone_call, event]
  end
end
