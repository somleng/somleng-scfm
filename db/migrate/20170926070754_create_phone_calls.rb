class CreatePhoneCalls < ApplicationMigration
  def change
    create_table :phone_calls do |t|
      t.references(:phone_number, :null => false, :index => true, :foreign_key => true)
      t.string(:status, :null => false)
      t.string(:remote_call_id, :index => {:unique => true})
      t.string(:remote_status)
      t.text(:remote_error_message)
      t.integer(:lock_version)
      t.public_send(json_column_type, :metadata, :null => false, :default => json_column_default)
      t.public_send(json_column_type, :remote_response, :null => false, :default => json_column_default)
      t.timestamps
    end
  end
end
