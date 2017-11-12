class CreateBatchOperations < ApplicationMigration
  def change
    create_table :batch_operations do |t|
      t.references(:callout, :index => true, :foreign_key => true)
      t.public_send(json_column_type, :parameters, :null => false, :default => json_column_default)
      t.public_send(json_column_type, :metadata, :null => false, :default => json_column_default)
      t.string(:status, :null => false)
      t.string(:type, :null => false)
      t.timestamps
    end
  end
end
