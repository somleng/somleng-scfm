require "rails_helper"

RSpec.describe AccessToken do
  let(:factory) { :access_token }
  include_examples "has_metadata"

  describe "destroying" do
    it "allows an unknown user to delete an access token" do
      access_token = create(:access_token)

      access_token.destroy

      expect(AccessToken.find_by_id(access_token.id)).to eq(nil)
    end

    it "allows the creator user to delete their own access token" do
      creator = create(:account)
      access_token = create(:access_token, created_by: creator)
      access_token.destroyer = creator

      access_token.destroy

      expect(AccessToken.find_by_id(access_token.id)).to eq(nil)
    end

    it "allows a super admin to delete an access token" do
      creator = create(:account)
      super_admin = create(:account, :super_admin)
      access_token = create(:access_token, created_by: creator)
      access_token.destroyer = super_admin

      access_token.destroy

      expect(AccessToken.find_by_id(access_token.id)).to eq(nil)
    end

    it "does not allow another user to destroy an access token" do
      creator = create(:account)
      destroyer = create(:account)
      access_token = create(:access_token, created_by: creator)
      access_token.destroyer = destroyer

      access_token.destroy

      expect(access_token).to be_present
      expect(access_token.errors[:base]).to be_present
      expect(access_token.errors[:base].first).to eq(
        I18n.t!(
          "activerecord.errors.models.access_token.attributes.base.restrict_destroy_status"
        )
      )
    end
  end

  describe "#to_json" do
    let(:parsed_json) { JSON.parse(subject.to_json) }
    let(:asserted_keys) { %w[id token created_at updated_at metadata permissions] }

    it {
      expect(parsed_json.keys).to match_array(asserted_keys)
    }
  end

  describe "#permissions_text" do
    it "displays all the permissions as a comma separated string" do
      access_token = build_stubbed(
        :access_token,
        permissions: %i[users_read users_write]
      )

      expect(access_token.permissions_text).to eq("Read users, Write users")
    end
  end
end
