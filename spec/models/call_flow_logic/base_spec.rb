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
end
