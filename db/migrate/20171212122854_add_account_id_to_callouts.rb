class AddAccountIdToCallouts < ActiveRecord::Migration[5.1]
  def up
    change_table(:callouts) do |t|
      t.references(:account, index: true, foreign_key: true)
    end

    if Callout.any?
      if Account.without_permissions.count > 1
        raise(ActiveRecord::IrreversibleMigration, "Cannot assign callouts to an account. More than one account exists")
      else
        account = Account.first_or_create!
      end

      Callout.update_all(account_id: account.id)
    end

    change_column(:callouts, :account_id, :bigint, null: false)
  end

  def down
    remove_reference(:callouts, :account)
  end
end
