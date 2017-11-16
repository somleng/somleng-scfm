class CreateCallouts < ApplicationMigration
  def change
    create_table :callouts do |t|
      t.string(:status, :null => false)
      t.string(:call_flow_logic)
      t.public_send(json_column_type, :metadata, :null => false, :default => json_column_default)
      t.timestamps
    end
  end
end
