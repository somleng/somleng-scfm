class AddAccountIdToBatchOperations < ApplicationMigration
  def up
    change_table(:batch_operations) do |t|
      t.references(:account, :index => true, :foreign_key => true)
    end

    if BatchOperation::Base.any?
      if Account.without_permissions.count > 1
        raise(ActiveRecord::IrreversibleMigration, "Cannot assign batch operations to an account. More than one account exists")
      else
        account = Account.first_or_create!
      end

      BatchOperation::Base.update_all(:account_id => account.id)
    end

    change_column(:batch_operations, :account_id, :bigint, :null => false)
  end

  def down
    remove_reference(:batch_operations, :account)
  end
end
