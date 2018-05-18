require "rails_helper"

RSpec.describe "API Key Management" do
  let(:user) { create(:admin) }

  it "shows all api keys for current account" do
    access_token1 = create(:access_token, resource_owner: user.account)
    access_token2 = create(:access_token, resource_owner: user.account)
    other_access_token = create(:access_token)

    sign_in(user)
    visit(dashboard_access_tokens_path)

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.access_tokens.index"),
        href: dashboard_access_tokens_path
      )
    end

    within("#resources") do
      expect(page).to have_content_tag_for(access_token1)
      expect(page).to have_content_tag_for(access_token2)
      expect(page).not_to have_content_tag_for(other_access_token)
      expect(page).to have_text("API Key")
      expect(page).to have_text(access_token1.token)
      expect(page).to have_text(access_token2.token)
      expect(page).to have_link(
        I18n.translate!(:"titles.actions.delete"),
        href: dashboard_access_token_path(access_token1)
      )
    end
  end

  it "can create a new access token" do
    sign_in(user)
    visit(dashboard_access_tokens_path)

    within("#button_toolbar") do
      click_link(I18n.translate!(:"titles.access_tokens.create"))
    end

    expect(current_path).to eq(dashboard_access_tokens_path)
    new_access_token = user.account.access_tokens.last
    expect(new_access_token).to be_present
  end

  it "can delete an access token" do
    access_token = create(:access_token, resource_owner: user.account)

    sign_in(user)
    visit(dashboard_access_tokens_path)

    within("#access_token_#{access_token.id}") do
      click_link(I18n.translate!(:"titles.actions.delete"))
    end

    expect(current_path).to eq(dashboard_access_tokens_path)
    expect(page).not_to have_content_tag_for(access_token)
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
