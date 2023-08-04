class AddIndexOnPhoneCallsStatusAndCalloutParticipationId < ActiveRecord::Migration[7.0]
  def change
    remove_index(:phone_calls, :callout_participation_id)
    add_index(:phone_calls, :callout_participation_id, unique: true, where: "status = 'created'")
  end
end
