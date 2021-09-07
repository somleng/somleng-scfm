class AddRemoteStatusFetchQueuedAtToPhoneCalls < ActiveRecord::Migration[6.1]
  def change
    add_column :phone_calls, :remote_status_fetch_queued_at, :datetime, index: true
  end
end
