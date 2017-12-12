class CreateAccounts < ApplicationMigration
  def change
    create_table :accounts do |t|
      t.public_send(json_column_type, :metadata, :null => false, :default => json_column_default)
      t.timestamps
    end
  end
end
