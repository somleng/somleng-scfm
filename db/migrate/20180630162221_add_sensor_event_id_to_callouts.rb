class AddSensorEventIdToCallouts < ActiveRecord::Migration[5.2]
  def change
    add_reference :callouts, :sensor_event
  end
end
