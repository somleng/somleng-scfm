class AddCallFlowLogicToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column(:accounts, :call_flow_logic, :string)
  end
end
