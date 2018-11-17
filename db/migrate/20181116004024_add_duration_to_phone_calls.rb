class AddDurationToPhoneCalls < ActiveRecord::Migration[5.2]
  def change
    add_column(:remote_phone_call_events, :call_duration, :integer, null: false, default: 0)
    add_column(:phone_calls, :duration, :integer, null: false, default: 0)

    reversible do |dir|
      dir.up do
        RemotePhoneCallEvent.where(
          "details->>'CallDuration' IS NOT NULL"
        ).update_all("call_duration = (details->>'CallDuration')::int")

        execute <<-SQL
        UPDATE phone_calls pc
        SET duration = rpce.call_duration
        FROM remote_phone_call_events rpce
        WHERE rpce.phone_call_id = pc.id AND rpce.call_duration > 0
        SQL
      end
    end
  end
end
