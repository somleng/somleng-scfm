class CreateContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :contacts do |t|
      t.string(:msisdn, null: false)
      t.jsonb(:metadata, null: false, default: {})
      t.index(:msisdn, unique: true)
      t.timestamps
    end
  end
end
