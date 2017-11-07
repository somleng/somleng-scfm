class CreateCalloutPopulations < ApplicationMigration
  def change
    create_table :callout_populations do |t|
      t.references(:callout, :null => false, :index => true, :foreign_key => true)
      t.public_send(json_column_type, :contact_filter_params, :null => false, :default => json_column_default)
      t.public_send(json_column_type, :metadata, :null => false, :default => json_column_default)
      t.timestamps
    end
  end
end
