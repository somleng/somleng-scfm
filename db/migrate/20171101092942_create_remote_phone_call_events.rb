class CreateRemotePhoneCallEvents < ApplicationMigration
  def change
    create_table :remote_phone_call_events do |t|
      t.references(:phone_call, :null => false, :index => true, :foreign_key => true)
      t.public_send(json_column_type, :details, :null => false, :default => json_column_default)
      t.public_send(json_column_type, :metadata, :null => false, :default => json_column_default)
      t.string("remote_call_id", :null => false)
      t.string("remote_direction", :null => false)
      t.string(:call_flow_logic, :null => false)
      t.timestamps
    end
  end
end
