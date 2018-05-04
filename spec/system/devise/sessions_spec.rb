require "rails_helper"

RSpec.describe "User sign in" do
  let(:user) { create(:user, password: "mysecret") }

  it "can sign in" do
    user = create(:user, password: "mysecret")

    visit new_user_session_path

    within("#page_title") do
      expect(page).to have_content(I18n.translate!(:"titles.user_sessions.new"))
    end

    fill_in "Email", with: user.email
    fill_in "Password", with: "mysecret"
    click_action_button(:create, key: :user_sessions)

    expect(page).to have_text("Signed in successfully.")
  end
end
