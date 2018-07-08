class AddLevelToSensorRules < ActiveRecord::Migration[5.2]
  def change
    add_column :sensor_rules, :level, :integer, null: false
    add_index :sensor_rules, :level
  end
end
