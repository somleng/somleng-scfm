class RemoveConditionalFromIndexOnPhoneCalls < ActiveRecord::Migration[6.0]
  def change
    remove_index(:phone_calls, %i[callout_participation_id status])
  end
end
