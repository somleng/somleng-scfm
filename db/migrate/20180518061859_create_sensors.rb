class CreateSensors < ActiveRecord::Migration[5.2]
  def change
    create_table :sensors do |t|
      t.jsonb :metadata, null: false, default: {}
      t.references :account, foreign_key: true, null: false
      t.string(:external_id, null: false)

      t.timestamps

      t.index(%i[account_id external_id], unique: true)
    end
  end
end
