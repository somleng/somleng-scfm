class ChangeAccountsTwilioAccountSidAndSomlengAccountSidToCitext < ActiveRecord::Migration[7.1]
  def change
    enable_extension("citext")

    reversible do |dir|
      dir.up do
        change_column(:accounts, :twilio_account_sid, :citext)
        change_column(:accounts, :somleng_account_sid, :citext)
      end

      dir.down do
        change_column(:accounts, :twilio_account_sid, :string)
        change_column(:accounts, :somleng_account_sid, :string)
      end
    end
  end
end
