class CreateContacts < ApplicationMigration
  def change
    create_table :contacts do |t|
      t.string(:msisdn, :null => false)
      t.public_send(json_column_type, :metadata, :null => false, :default => json_column_default)
      t.index(:msisdn, :unique => true)
      t.timestamps
    end
  end
end
