class AddLevelToSensorRules < ActiveRecord::Migration[5.2]
  def change
    add_column :sensor_rules, :level, :integer

    reversible do |dir|
      dir.up do
        SensorRule.update_all(level: 0)
      end
    end

    change_column_null(:sensor_rules, :level, false)
    add_index :sensor_rules, :level
  end
end
