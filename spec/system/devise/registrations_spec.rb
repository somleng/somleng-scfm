require 'rails_helper'

RSpec.describe "Registrations" do
  it "can update the users password" do
    user = create(:user)

    sign_in(user)
    visit edit_user_registration_path

    fill_in "Current password", with: user.password
    fill_in "Password", with: "new-password", match: :prefer_exact
    fill_in "Password confirmation", with: "new-password"
    click_on "Save"

    expect(page).to have_text("Your account has been updated successfully.")
    expect(current_path).to eq(user_root_path)
  end
end
