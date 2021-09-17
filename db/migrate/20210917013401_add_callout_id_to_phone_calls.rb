class AddCalloutIdToPhoneCalls < ActiveRecord::Migration[6.1]
  def change
    add_reference :phone_calls, :callout, foreign_key: true
  end
end
