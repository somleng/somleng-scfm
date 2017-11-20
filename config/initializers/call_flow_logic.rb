if registered_call_flow_logic = ENV["REGISTERED_CALL_FLOW_LOGIC"]
  CallFlowLogic::Base.register(*registered_call_flow_logic.to_s.split(","))
end
