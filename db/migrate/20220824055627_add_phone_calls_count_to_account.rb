class AddPhoneCallsCountToAccount < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :phone_calls_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Account.find_each do |account|
          Account.reset_counters(account.id, :phone_calls)
        end
      end
    end
  end
end
