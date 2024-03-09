class AddAudioURLToCallouts < ActiveRecord::Migration[5.2]
  def change
    add_column(:callouts, :audio_url, :string)
  end
end
