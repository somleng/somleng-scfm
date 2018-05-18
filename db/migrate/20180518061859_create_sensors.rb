class CreateSensors < ActiveRecord::Migration[5.2]
  def change
    create_table :sensors do |t|
      t.jsonb :metadata
      t.belongs_to :account, foreign_key: true

      t.timestamps
    end
  end
end
