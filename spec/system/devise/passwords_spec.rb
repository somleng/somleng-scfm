require "rails_helper"

RSpec.describe "Passwords" do
  it "can send password reset instructions" do
    user = create(:user)

    visit new_user_password_path

    fill_in "Email", with: user.email
    click_on "Forgot your password?"

    expect(page).to have_content("You will receive an email with instructions")
  end

  it "can reset my password" do
    user = create(:user)
    token = user.send_reset_password_instructions

    visit edit_user_password_path(reset_password_token: token)

    fill_in "New password", with: "12345678"
    fill_in "Confirm your new password", with: "12345678"
    click_on "Save"

    expect(page).to have_text(
      "Your password has been changed successfully. You are now signed in."
    )
    expect(current_path).to eq(user_root_path)
  end
end
