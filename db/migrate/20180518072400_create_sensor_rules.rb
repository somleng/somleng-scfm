class CreateSensorRules < ActiveRecord::Migration[5.2]
  def change
    create_table :sensor_rules do |t|
      t.belongs_to :sensor, foreign_key: true
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
  end
end
