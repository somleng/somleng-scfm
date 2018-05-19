class UpdateIndexContactsOnMsisdn < ActiveRecord::Migration[5.1]
  def up
    remove_index(:contacts, :msisdn)
    add_index(:contacts, %i[account_id msisdn], unique: true)
  end

  def down
    remove_index(:contacts, %i[account_id msisdn])
    add_index(:contacts, :msisdn, unique: true)
  end
end
