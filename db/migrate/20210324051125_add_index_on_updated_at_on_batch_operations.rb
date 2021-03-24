class AddIndexOnUpdatedAtOnBatchOperations < ActiveRecord::Migration[6.0]
  def change
    add_index(:batch_operations, :updated_at)
  end
end
