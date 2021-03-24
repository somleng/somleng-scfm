class AddIndexOnStatusToBatchOperations < ActiveRecord::Migration[6.0]
  def change
    add_index(:batch_operations, :status)
    add_index(:batch_operations, :created_at)
  end
end
