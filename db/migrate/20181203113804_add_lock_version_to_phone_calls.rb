class AddLockVersionToPhoneCalls < ActiveRecord::Migration[5.2]
  def change
    add_column(:phone_calls, :lock_version, :integer, null: false, default: 0)
  end
end
