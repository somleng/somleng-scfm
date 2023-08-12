require "rails_helper"

RSpec.describe "Users" do
  let(:user) { create(:user) }

  it "can list all users" do
    user = create(:user)
    other_user = create(:user, account: user.account)

    sign_in(user)
    visit dashboard_users_path

    expect(page).to have_title("Users")

    within("#page_actions") do
      expect(page).to have_link("New", href: new_user_invitation_path)
    end

    within("#resources") do
      expect(page).to have_content("#")

      expect(page).to have_link(
        other_user.id.to_s,
        href: dashboard_user_path(other_user)
      )

      expect(other_user.email).to appear_before(user.email)
    end
  end

  it "can show a user" do
    user = create(:user)

    sign_in(user)
    visit dashboard_user_path(user)

    expect(page).to have_title("User #{user.id}")

    within("#page_actions") do
      expect(page).to have_link("Edit", href: edit_dashboard_user_path(user))
    end

    within(".user") do
      expect(page).to have_content(user.id)
    end
  end

  it "can update a user" do
    user = create(:user)
    other_user = create(:user, account: user.account)

    sign_in(user)
    visit edit_dashboard_user_path(other_user)

    expect(page).to have_title("Edit User")

    fill_in_key_value_for(:metadata, with: { key: "name", value: "Bob Chann" })
    click_on("Save")

    expect(page).to have_text("User was successfully updated.")
    expect(page).to have_content("Bob Chann")
  end

  it "can delete a user" do
    user = create(:user)
    other_user = create(:user, account: user.account)

    sign_in(user)
    visit dashboard_user_path(other_user)

    within("#page_actions") do
      click_on "Delete"
    end

    expect(page).to have_text("User was successfully destroyed.")
  end
end
