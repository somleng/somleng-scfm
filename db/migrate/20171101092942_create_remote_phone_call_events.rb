class CreateRemotePhoneCallEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :remote_phone_call_events do |t|
      t.references(:phone_call, null: false, index: true, foreign_key: true)
      t.jsonb(:details, null: false, default: {})
      t.jsonb(:metadata, null: false, default: {})
      t.string("remote_call_id", null: false)
      t.string("remote_direction", null: false)
      t.string(:call_flow_logic, null: false)
      t.timestamps
    end
  end
end
