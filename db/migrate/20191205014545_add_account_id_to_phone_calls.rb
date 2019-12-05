class AddAccountIdToPhoneCalls < ActiveRecord::Migration[6.0]
  def change
    add_reference(:phone_calls, :account, foreign_key: true)

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE phone_calls pc
          SET account_id = c.account_id
          FROM contacts c
          WHERE pc.contact_id = c.id
        SQL
      end
    end

    change_column_null(:phone_calls, :account_id, false)
  end
end
