class CreateBatchOperations < ActiveRecord::Migration[5.1]
  def change
    create_table :batch_operations do |t|
      t.references(:callout, index: true, foreign_key: true)
      t.jsonb(:parameters, null: false, default: {})
      t.jsonb(:metadata, null: false, default: {})
      t.string(:status, null: false)
      t.string(:type, null: false)
      t.timestamps
    end
  end
end
