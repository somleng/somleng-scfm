class CreateCalloutParticipants < ApplicationMigration
  def change
    create_table :callout_participants do |t|
      t.references(:callout, :foreign_key => true, :index => true, :null => false)
      t.references(:contact, :foreign_key => true, :index => true, :null => false)
      t.string(:msisdn, :null => false)
      t.public_send(json_column_type, :metadata, :null => false, :default => json_column_default)
      t.index([:callout_id, :msisdn], :unique => true)
      t.index([:callout_id, :contact_id], :unique => true)
      t.timestamps
    end
  end
end
