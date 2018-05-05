require "rails_helper"

RSpec.describe "API Key Management" do
  let(:admin) { create(:user, roles: :admin) }

  it "shows all api keys for current account" do
    access_token1 = create(:access_token, resource_owner: admin.account)
    access_token2 = create(:access_token, resource_owner: admin.account)

    sign_in(admin)
    visit(dashboard_access_tokens_path)

    within("#page_title") do
      expect(page).to have_text(I18n.translate!(:"titles.access_tokens.index"))
    end

    within("#access_tokens") do
      expect(page).to have_text("API Key")
      expect(page).to have_text(access_token1.token)
      expect(page).to have_text(access_token2.token)
    end
  end

  it "does not show api keys from other accounts" do
    access_token = create(:access_token, resource_owner: admin.account)
    other_access_token = create(:access_token)

    sign_in(admin)
    visit dashboard_access_tokens_path

    expect(page).to have_text(access_token.token)
    expect(page).not_to have_text(other_access_token.token)
  end

  context "when a user is not an admin tries to api key page" do
    let(:user) { create(:user) }

    it "redirect to default page with alert message" do
      sign_in(user)

      visit dashboard_access_tokens_path

      expect(page).to have_text("We're sorry, but you do not have permission to view this page.")
    end
  end
end
