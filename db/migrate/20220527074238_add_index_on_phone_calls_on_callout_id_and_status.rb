class AddIndexOnPhoneCallsOnCalloutIdAndStatus < ActiveRecord::Migration[6.1]
  def change
    add_index(:phone_calls, [:callout_id, :status])
  end
end
