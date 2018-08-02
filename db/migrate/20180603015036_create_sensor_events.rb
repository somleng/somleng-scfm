class CreateSensorEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :sensor_events do |t|
      t.references(:sensor, null: false, foreign_key: true)
      t.references(:sensor_rule, foreign_key: true)
      t.jsonb(:payload, null: false, default: {})
      t.timestamps
    end
  end
end
