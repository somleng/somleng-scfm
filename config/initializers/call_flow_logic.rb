if registered_call_flow_logic = ENV["REGISTERED_CALL_FLOW_LOGIC"]
  permitted_call_flow_logic = CallFlowLogic::Base.descendents.map(&:to_s)

  registered_call_flow_logic.to_s.split(",").each do |call_flow_logic|
    CallFlowLogic::Base.register(call_flow_logic) if permitted_call_flow_logic.include?(call_flow_logic)
  end
end
