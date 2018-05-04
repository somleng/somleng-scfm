require "rails_helper"

RSpec.describe "Users" do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  it "can list all users" do
    user = create(:user)
    other_user = create(:user, account: user.account)
    different_user = create(:user)

    sign_in(user)

    visit dashboard_users_path

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :new, key: :user_invitations, href: new_user_invitation_path
      )
    end

    within("#users") do
      expect(page).to have_content("#")
      expect(page).to have_content(user.id)
      expect(page).to have_content(other_user.id)
      expect(page).to have_content("Email")
      expect(page).to have_content(user.email)
      expect(page).to have_content(other_user.email)
      expect(page).to have_no_content(different_user.email)
      expect(page).to have_content("Last Signed In")
    end
  end
end
