class AddCallFlowLogicAndPlatformProviderNameToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column(:accounts, :call_flow_logic, :string)
    add_column(:accounts, :platform_provider_name, :string)
  end
end
