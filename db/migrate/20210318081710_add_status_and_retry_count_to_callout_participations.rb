class AddStatusAndRetryCountToCalloutParticipations < ActiveRecord::Migration[6.0]
  def change
    add_column :callout_participations, :answered, :boolean, default: false, null: false, index: true
    add_column :callout_participations, :phone_calls_count, :integer, null: false, default: 0, index: true

    remove_column :phone_calls, :create_batch_operation_id, :bigint
    remove_column :phone_calls, :queue_batch_operation_id, :bigint
    remove_column :phone_calls, :queue_remote_fetch_batch_operation_id, :bigint
    remove_column :phone_calls, :remote_request_params

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE callout_participations
          SET phone_calls_count = (SELECT count(1)
                                   FROM phone_calls
                                   WHERE callout_participations.id = phone_calls.callout_participation_id);

          UPDATE callout_participations
          SET answered = EXISTS (SELECT id
                                 FROM phone_calls
                                 WHERE callout_participations.id = phone_calls.callout_participation_id
                                 AND phone_calls.status = 'completed')
        SQL

        BatchOperation::Base.where(
          type: [
            "BatchOperation::PhoneCallCreate",
            "BatchOperation::PhoneCallEventOperation",
            "BatchOperation::PhoneCallOperation",
            "BatchOperation::PhoneCallQueueRemoteFetch",
            "BatchOperation::PhoneCallQueue"
          ]
        )

        Account.update_all(
          settings: {
            from_phone_number: "1294",
            phone_call_queue_limit: 200,
            max_phone_calls_for_callout_participation: 3
          }
        )
      end
    end

    add_index :phone_calls, :created_at
    add_index :phone_calls, :remotely_queued_at
    add_index :phone_calls, :msisdn
    add_index :phone_calls, :status
    add_index :callouts, :status
    add_index :contacts, :created_at
    add_index :contacts, :updated_at
  end
end
