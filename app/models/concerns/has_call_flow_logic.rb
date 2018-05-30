module HasCallFlowLogic
  extend ActiveSupport::Concern

  included do
    validates :call_flow_logic, call_flow_logic: true
  end

  def call_flow_logic=(value)
    write_attribute(:call_flow_logic, value.presence)
  end
end
