require 'rails_helper'

RSpec.describe "Registrations" do
  it "can update the users password" do
    user = create(:user)

    sign_in(user)
    visit edit_user_registration_path

    within("#page_title") do
      expect(page).to have_content(I18n.translate!(:"titles.user_registrations.edit"))
    end

    fill_in "Current password", with: user.password
    fill_in "Password", with: "new-password"
    fill_in "Password confirmation", with: "new-password"
    click_action_button(:update, key: :user_registrations)

    expect(page).to have_text("Your account has been updated successfully.")
  end
end
