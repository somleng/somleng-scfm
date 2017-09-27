class CreatePhoneNumbers < ActiveRecord::Migration[5.1]
  def change
    create_table :phone_numbers do |t|
      t.references(:callout, :foreign_key => true, :index => true, :null => false)
      t.string(:msisdn, :null => false)
      t.index([:callout_id, :msisdn], :unique => true)
      t.timestamps
    end
  end
end
