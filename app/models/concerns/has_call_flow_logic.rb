module HasCallFlowLogic
  extend ActiveSupport::Concern

  included do
    validates :call_flow_logic, :call_flow_logic => true
  end
end
