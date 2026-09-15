class CreateGeocodeTargetAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :geocode_target_areas do |t|
      t.references :broadcast, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.integer :administrative_level, null: false
      t.string :path, array: true, null: false
      t.string :geocode, null: false
      t.index [ :broadcast_id, :path ], unique: true
      t.index [ :administrative_level, :geocode ]

      t.timestamps
    end
  end
end
