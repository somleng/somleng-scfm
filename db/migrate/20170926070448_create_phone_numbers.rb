class CreatePhoneNumbers < ActiveRecord::Migration[5.1]
  def change
    create_table :phone_numbers do |t|
      t.string :msisdn, :null => false, :index => {:unique => true}
      t.timestamps
    end
  end
end
