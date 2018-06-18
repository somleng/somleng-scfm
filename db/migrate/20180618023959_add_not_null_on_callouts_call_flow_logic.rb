class AddNotNullOnCalloutsCallFlowLogic < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:callouts, :call_flow_logic, true)
  end
end
