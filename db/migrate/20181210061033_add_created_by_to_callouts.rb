class AddCreatedByToCallouts < ActiveRecord::Migration[5.2]
  def change
    add_reference(:callouts, :created_by, foreign_key: { to_table: :users })
  end
end
