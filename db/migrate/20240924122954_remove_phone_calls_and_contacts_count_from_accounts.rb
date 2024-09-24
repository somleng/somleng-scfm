class RemovePhoneCallsAndContactsCountFromAccounts < ActiveRecord::Migration[7.1]
  def change
    remove_column(:accounts, :contacts_count, :integer, default: 0, null: false)
    remove_column(:accounts, :phone_calls_count, :integer, default: 0, null: false)
  end
end
