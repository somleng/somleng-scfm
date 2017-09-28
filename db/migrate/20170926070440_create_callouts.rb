class CreateCallouts < ActiveRecord::Migration[5.1]
  def change
    create_table :callouts do |t|
      json_column_type = ActiveRecord::Base.connection.adapter_name.downcase == "postgresql" ? :json : :text
      t.public_send(json_column_type, :metadata, :null => false, :default => '{}')
      t.timestamps
    end
  end
end
