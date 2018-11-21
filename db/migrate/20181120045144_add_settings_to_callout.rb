class AddSettingsToCallout < ActiveRecord::Migration[5.2]
  def change
    add_column(:callouts, :settings, :jsonb, default: {}, null: false)
  end
end
