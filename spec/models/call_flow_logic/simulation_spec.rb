require "rails_helper"

RSpec.describe CallFlowLogic::Simulation do
  it_behaves_like("call_flow_logic")

  it "overrides the from parameter" do
    phone_call = build_stubbed(:phone_call)
    call_flow_logic = described_class.new(phone_call: phone_call)

    expect(call_flow_logic.remote_request_params.fetch("from")).to eq("999999")
  end
end
  
