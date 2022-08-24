class AddContactsCountToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :contacts_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Account.find_each do |account|
          Account.reset_counters(account.id, :contacts)
        end
      end
    end
  end
end
