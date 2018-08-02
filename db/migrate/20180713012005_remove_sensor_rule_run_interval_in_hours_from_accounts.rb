class RemoveSensorRuleRunIntervalInHoursFromAccounts < ActiveRecord::Migration[5.2]
  def change
    remove_column(:accounts, :sensor_rule_run_interval_in_hours, :integer)
  end
end
