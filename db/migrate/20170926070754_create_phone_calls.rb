class CreatePhoneCalls < ActiveRecord::Migration[5.1]
  def change
    create_table :phone_calls do |t|
      t.references(:phone_number, :null => false, :index => true, :foreign_key => true)
      t.string(:status, :null => false)

      t.string(:remote_call_id, :index => {:unique => true})
      t.string(:remote_status)
      t.text(:remote_response, :null => false, :default => '{}')
      t.timestamps
    end
  end
end
