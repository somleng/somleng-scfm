class CreateAccounts < ApplicationMigration
  def change
    create_table :accounts do |t|
      t.public_send(json_column_type, :metadata, :null => false, :default => json_column_default)
      t.public_send(json_column_type, :settings, :null => false, :default => json_column_default)
      t.string(:twilio_account_sid)
      t.string(:somleng_account_sid)
      t.string(:twilio_auth_token)
      t.string(:somleng_auth_token)
      t.index(:twilio_account_sid, :unique => true)
      t.index(:somleng_account_sid, :unique => true)
      t.integer(:permissions, :default => Account::DEFAULT_PERMISSIONS_BITMASK, :null => false)
      t.timestamps
    end
  end
end
