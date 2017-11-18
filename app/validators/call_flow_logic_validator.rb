class CallFlowLogicValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && !registered_call_flow_logic.include?(value)
      record.errors.add(attribute, :inclusion)
    end
  end

  private

  def registered_call_flow_logic
    CallFlowLogic::Base.registered.map(&:to_s)
  end
end
