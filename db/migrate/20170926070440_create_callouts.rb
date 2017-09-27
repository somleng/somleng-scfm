class CreateCallouts < ActiveRecord::Migration[5.1]
  def change
    create_table :callouts do |t|
      t.text(:metadata, :null => false, :default => '{}')
      t.timestamps
    end
  end
end
