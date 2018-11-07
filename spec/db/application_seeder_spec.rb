require "rails_helper"
require Rails.root.join("db/application_seeder")

RSpec.describe ApplicationSeeder do
  describe "#seed!" do
    it "creates a super admin account" do
      _existing_account = create(:account)

      subject.seed!

      super_admin_account = Account.with_permissions(:super_admin).first
      expect(super_admin_account.access_tokens.count).to eq(1)
      expect(Account.count).to eq(2)
    end
  end
end
