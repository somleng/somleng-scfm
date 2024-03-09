class CreateRecordings < ActiveRecord::Migration[7.1]
  def change
    create_table :recordings do |t|
      t.references :phone_call, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.string :external_recording_id, null: false
      t.string :external_recording_url, null: false
      t.integer :duration, null: false

      t.timestamps

      t.index(:created_at)
    end
  end
end
