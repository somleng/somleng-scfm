class AddRolesToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :roles, :integer, default: 1, null: false
  end
end
