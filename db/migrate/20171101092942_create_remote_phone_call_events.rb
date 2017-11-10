class CreateRemotePhoneCallEvents < ApplicationMigration
  def change
    create_table :remote_phone_call_events do |t|
      t.references(:phone_call, :null => false, :index => true, :foreign_key => true)
      t.public_send(json_column_type, :details, :null => false, :default => json_column_default)
      t.timestamps
    end
  end
end
