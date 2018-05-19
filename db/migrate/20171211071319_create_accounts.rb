class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.jsonb(:metadata, null: false, default: {})
      t.jsonb(:settings, null: false, default: {})
      t.string(:twilio_account_sid)
      t.string(:somleng_account_sid)
      t.string(:twilio_auth_token)
      t.string(:somleng_auth_token)
      t.index(:twilio_account_sid, unique: true)
      t.index(:somleng_account_sid, unique: true)
      t.integer(:permissions, default: Account::DEFAULT_PERMISSIONS_BITMASK, null: false)
      t.timestamps
    end
  end
end
