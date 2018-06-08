require "rails_helper"

RSpec.describe "User sign in" do
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

  it "can sign out" do
    user = create(:user)

    sign_in(user)
    visit dashboard_root_path

    within("#top_nav") do
      click_action_button(:destroy, key: :user_sessions, type: :link)
    end

    expect(current_path).to eq(new_user_session_path)
  end
end
