class UpdateIndexContactsOnMsisdn < ApplicationMigration
  def up
    remove_index(:contacts, :msisdn)
    add_index(:contacts, [:account_id, :msisdn], :unique => true)
  end

  def down
    remove_index(:contacts, [:account_id, :msisdn])
    add_index(:contacts, :msisdn, :unique => true)
  end
end
