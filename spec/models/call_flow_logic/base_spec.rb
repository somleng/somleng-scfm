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
      event = create_event
      call_flow_logic = described_class.new(event: event)

      call_flow_logic.run!

      expect(event.phone_call.reload).to be_in_progress
    end

    it "retries ActiveRecord::StaleObjectError" do
      event = create_event
      call_flow_logic = described_class.new(event: event)
      PhoneCall.find(event.phone_call.id).touch

      call_flow_logic.run!

      expect(event.phone_call.reload).to be_in_progress
    end
  end

  def create_event
    phone_call = create(:phone_call, :created, remote_status: "in-progress")
    create(:remote_phone_call_event, phone_call: phone_call)
  end
end
