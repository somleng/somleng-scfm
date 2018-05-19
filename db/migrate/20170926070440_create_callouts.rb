class CreateCallouts < ActiveRecord::Migration[5.1]
  def change
    create_table :callouts do |t|
      t.string(:status, null: false)
      t.string(:call_flow_logic)
      t.jsonb(:metadata, null: false, default: {})
      t.timestamps
    end
  end
end
