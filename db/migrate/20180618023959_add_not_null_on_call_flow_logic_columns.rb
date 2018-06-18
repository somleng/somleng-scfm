class AddNotNullOnCallFlowLogicColumns < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:callouts, :call_flow_logic, false)
    change_column_null(:callout_participations, :call_flow_logic, false)
    change_column_null(:phone_calls, :call_flow_logic, false)
    change_column_null(:accounts, :call_flow_logic, false)
  end
end
