class AddSensorRuleRunIntervalInHoursToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :sensor_rule_run_interval_in_hours, :integer
    add_column :sensor_rules, :last_run_at, :datetime
  end
end
