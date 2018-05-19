class CreatePhoneCalls < ActiveRecord::Migration[5.1]
  def change
    create_table :phone_calls do |t|
      t.references(:callout_participation, index: true, foreign_key: true)
      t.references(:contact, null: false, index: true, foreign_key: true)
      t.references(
        :create_batch_operation,
        index: true,
        foreign_key: {
          to_table: :batch_operations
        }
      )
      t.references(
        :queue_batch_operation,
        index: true,
        foreign_key: {
          to_table: :batch_operations
        }
      )
      t.references(
        :queue_remote_fetch_batch_operation,
        index: true,
        foreign_key: {
          to_table: :batch_operations
        }
      )
      t.string(:status, null: false)
      t.string(:msisdn, null: false)
      t.string(:remote_call_id, index: { unique: true })
      t.string(:remote_status)
      t.string(:remote_direction)
      t.text(:remote_error_message)
      t.jsonb(:metadata, null: false, default: {})
      t.jsonb(:remote_response, null: false, default: {})
      t.jsonb(:remote_request_params, null: false, default: {})
      t.jsonb(:remote_queue_response, null: false, default: {})
      t.string(:call_flow_logic)
      t.datetime "remotely_queued_at"
      t.timestamps
    end
  end
end
