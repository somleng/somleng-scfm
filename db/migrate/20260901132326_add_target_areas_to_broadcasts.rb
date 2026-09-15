class AddTargetAreasToBroadcasts < ActiveRecord::Migration[8.1]
  def change
    add_column(:broadcasts, :target_areas, :jsonb, null: false, default: {})
  end
end
