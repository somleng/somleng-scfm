class AddUniqueIndexOnPhoneCallsAndParticipationState < ActiveRecord::Migration[5.2]
  def change
    add_index(
      :phone_calls, %i[callout_participation_id status],
      unique: true, where: "status = 'created'"
    )
  end
end
