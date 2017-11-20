if names = ENV["REGISTERED_CALL_FLOW_LOGIC"]
  class_names = names.to_s.split(",").map { |name| klass = name.constantize rescue nil; klass && klass.to_s }.compact
  CallFlowLogic::Base.register(*class_names)
end
