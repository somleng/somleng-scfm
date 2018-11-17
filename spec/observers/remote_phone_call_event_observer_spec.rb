require "rails_helper"

RSpec.describe RemotePhoneCallEventObserver do
  include FactoryHelpers

  describe "#remote_phone_call_event_initialized(remote_phone_call_event)" do
    class MyCallFlowLogic < CallFlowLogic::Base; end

    it "handles new phone calls" do
      account = create_account(call_flow_logic: MyCallFlowLogic)
      event = build_event(
        account: account, direction: "inbound", call_status: "in-progress"
      )
      observer = described_class.new

      observer.remote_phone_call_event_initialized(event)

      expect(event.errors).to be_empty
      expect(event.remote_call_id).to eq(event.details.fetch("CallSid"))
      expect(event.remote_direction).to eq("inbound")
      expect(event.call_flow_logic).to eq(MyCallFlowLogic.to_s)
      expect(event.phone_call.call_flow_logic).to eq(MyCallFlowLogic.to_s)
      expect(event.phone_call).to be_present
      expect(event.phone_call.remote_call_id).to eq(event.remote_call_id)
      expect(event.phone_call.remote_direction).to eq("inbound")
      expect(event.phone_call.msisdn).to eq(event.details.fetch("From"))
      expect(event.phone_call.remote_status).to eq("in-progress")
    end

    it "handles existing phone calls" do
      account = create_account(call_flow_logic: MyCallFlowLogic)
      phone_call = create_phone_call(
        :remotely_queued,
        account: account,
        call_flow_logic: CallFlowLogic::HelloWorld,
        remote_status: "queued"
      )
      event = build_event(
        account: account,
        remote_call_id: phone_call.remote_call_id,
        call_status: "completed",
        call_duration: "87"
      )
      observer = described_class.new

      observer.remote_phone_call_event_initialized(event)

      expect(event.phone_call).to eq(phone_call)
      expect(event.call_flow_logic).to eq(CallFlowLogic::HelloWorld.to_s)
      expect(event.call_duration).to eq(87)
      expect(event.phone_call.remote_status).to eq("completed")
      expect(event.phone_call.duration).to eq(87)
    end

    it "does not override the phone call's duration" do
      account = create(:account)
      phone_call = create_phone_call(
        :remotely_queued, account: account, duration: 87
      )
      event = build_event(
        account: account,
        remote_call_id: phone_call.remote_call_id,
        call_duration: 0
      )
      observer = described_class.new

      observer.remote_phone_call_event_initialized(event)

      expect(event.phone_call).to eq(phone_call)
      expect(event.phone_call.duration).to eq(87)
    end

    def build_event(options = {})
      build(
        :remote_phone_call_event,
        call_flow_logic: options.fetch(:call_flow_logic) { nil },
        details: generate_event_details(
          account_sid: options.fetch(:account).somleng_account_sid,
          remote_call_id: options.fetch(:remote_call_id) { nil },
          call_status: options.fetch(:call_status) { nil },
          call_duration: options.fetch(:call_duration) { nil },
          direction: options.fetch(:direction) { nil }
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

    def generate_event_details(options = {})
      {
        "CallSid" => options[:remote_call_id],
        "AccountSid" => options[:account_sid],
        "CallStatus" => options[:call_status],
        "CallDuration" => options[:call_duration],
        "Direction" => options[:direction]
      }.compact.reverse_merge(generate(:twilio_remote_call_event_details))
    end
  end
end
