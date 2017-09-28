class CreatePhoneNumbers < ApplicationMigration
  def change
    create_table :phone_numbers do |t|
      t.references(:callout, :foreign_key => true, :index => true, :null => false)
      t.string(:msisdn, :null => false)
      t.public_send(json_column_type, :metadata, :null => false, :default => json_column_default)
      t.index([:callout_id, :msisdn], :unique => true)
      t.timestamps
    end
  end
end
