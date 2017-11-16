class CallFlowLogicValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && !allowed_call_flow_logic.include?(value)
      record.errors.add(attribute, :inclusion)
    end
  end

  private

  def allowed_call_flow_logic
    @allowed_call_flow_logic ||= CallFlowLogic::Base.descendants.map(&:to_s)
  end
end
