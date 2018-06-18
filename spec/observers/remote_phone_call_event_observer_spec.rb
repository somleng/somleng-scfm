require "rails_helper"

RSpec.describe RemotePhoneCallEventObserver do
  include FactoryHelpers

  describe "#remote_phone_call_event_initialized(remote_phone_call_event)" do
    class MyCallFlowLogic < CallFlowLogic::Base; end

    it "handles new phone calls" do
      account = create_account(call_flow_logic: MyCallFlowLogic)
      event = build_event(account: account)

      subject.remote_phone_call_event_initialized(event)

      expect(event.errors).to be_empty
      expect(event.remote_call_id).to eq(event.details.fetch("CallSid"))
      expect(event.remote_direction).to eq(event.details.fetch("Direction"))
      expect(event.call_flow_logic).to eq(MyCallFlowLogic.to_s)
      expect(event.phone_call.call_flow_logic).to eq(event.call_flow_logic)
      expect(event.phone_call).to be_present
      expect(event.phone_call.remote_call_id).to eq(event.remote_call_id)
      expect(event.phone_call.remote_direction).to eq(event.remote_direction)
      expect(event.phone_call.msisdn).to eq(event.details.fetch("From"))
      expect(event.phone_call.remote_status).to eq(event.details.fetch("CallStatus"))
    end

    it "handles existing phone calls" do
      account = create_account(call_flow_logic: MyCallFlowLogic)
      phone_call = create_phone_call(
        account: account,
        call_flow_logic: CallFlowLogic::HelloWorld,
        remote_call_id: SecureRandom.uuid,
        remote_status: "queued"
      )
      event = build_event(
        account: account,
        remote_call_id: phone_call.remote_call_id,
        call_status: "completed"
      )

      subject.remote_phone_call_event_initialized(event)

      expect(event.phone_call).to eq(phone_call)
      expect(event.call_flow_logic).to eq(CallFlowLogic::HelloWorld.to_s)
      expect(event.phone_call.remote_status).to eq("completed")
    end

    def build_event(account:, call_flow_logic: nil, remote_call_id: nil, call_status: nil)
      build(
        :remote_phone_call_event,
        call_flow_logic: call_flow_logic,
        details: generate_event_details(
          account_sid: account.somleng_account_sid,
          remote_call_id: remote_call_id,
          call_status: call_status
        ),
        build_phone_call: false
      )
    end

    def create_account(call_flow_logic: nil)
      create(
        :account,
        somleng_account_sid: generate(:somleng_account_sid),
        call_flow_logic: call_flow_logic.to_s.presence
      )
    end

    def generate_event_details(remote_call_id: nil, account_sid: nil, call_status: nil)
      details = generate(:twilio_remote_call_event_details)
      details["CallSid"] = remote_call_id if remote_call_id
      details["AccountSid"] = account_sid if account_sid
      details["CallStatus"] = call_status if call_status
      details
    end
  end
end
