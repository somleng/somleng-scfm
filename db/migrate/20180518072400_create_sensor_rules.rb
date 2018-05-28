class CreateSensorRules < ActiveRecord::Migration[5.2]
  def change
    create_table :sensor_rules do |t|
      t.references :sensor, foreign_key: true, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
  end
end
