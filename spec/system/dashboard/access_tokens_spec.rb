require "rails_helper"

RSpec.describe "API Key Management" do
  it "shows all api keys for current account" do
    user = create(:user)
    sign_in(user)
    access_token1 = create(:access_token, resource_owner: user.account)
    access_token2 = create(:access_token, resource_owner: user.account)

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
    user = create(:user)
    sign_in(user)
    access_token = create(:access_token, resource_owner: user.account)
    other_access_token = create(:access_token)

    visit(dashboard_access_tokens_path)

    expect(page).to have_text(access_token.token)
    expect(page).not_to have_text(other_access_token.token)
  end
end
