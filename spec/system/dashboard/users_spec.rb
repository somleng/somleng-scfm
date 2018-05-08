require "rails_helper"

RSpec.describe "Users" do
  let(:admin) { create(:admin) }

  context "when a user is not an admin tries to users page" do
    let(:user) { create(:user) }

    it "render page 401" do
      sign_in(user)

      visit dashboard_users_path

      expect(page).to have_text("We're sorry, but you do not have permission to view this page.")
    end
  end

  it "can list all users" do
    user = create(:admin)
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

  describe "show user detail page" do
    it "click delete user" do
      user = create(:user, account: admin.account)

      sign_in(admin)
      visit dashboard_user_path(user)

      click_button "Delete"

      expect(page).to have_text("User was successfully destroyed.")
    end

    it "can update user roles" do
      user = create(:user, account: admin.account)

      sign_in(admin)
      visit dashboard_user_path(user)

      edit_user(roles: "Admin", location: "Banteay Meanchey")
      user.reload

      expect(page).to have_text("User was successfully updated.")
      expect(user.roles?(:admin)).to eq true
      expect(user.location_ids).to include_location("Banteay Meanchey")
    end
  end

  def edit_user(options = {})
    click_button "Edit"
    choose options[:roles]
    select options[:location], from: "Locations"
    click_button("Update User")
  end
end
