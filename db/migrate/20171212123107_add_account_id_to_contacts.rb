class AddAccountIdToContacts < ApplicationMigration
  def up
    change_table(:contacts) do |t|
      t.references(:account, :index => true, :foreign_key => true)
    end

    if Contact.any?
      if Account.without_permissions.count > 1
        raise(ActiveRecord::IrreversibleMigration, "Cannot assign contacts to an account. More than one account exists")
      else
        account = Account.first_or_create!
      end

      Contact.update_all(:account_id => account.id)
    end

    change_column(:contacts, :account_id, :bigint, :null => false)
  end

  def down
    remove_reference(:contacts, :account)
  end
end
