class CreateCalloutParticipations < ApplicationMigration
  def change
    create_table :callout_participations do |t|
      t.references(:callout, :foreign_key => true, :index => true, :null => false)
      t.references(:contact, :foreign_key => true, :index => true, :null => false)
      t.references(
        :callout_population,
        :index => true,
        :foreign_key => {
          :to_table => :batch_operations
        }
      )
      t.string(:msisdn, :null => false)
      t.string(:call_flow_logic)
      t.public_send(json_column_type, :metadata, :null => false, :default => json_column_default)
      t.index([:callout_id, :msisdn], :unique => true)
      t.index([:callout_id, :contact_id], :unique => true)
      t.timestamps
    end
  end
end
