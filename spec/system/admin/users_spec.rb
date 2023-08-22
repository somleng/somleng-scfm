require "rails_helper"

RSpec.describe "Admin/Users" do
  it "List users" do
    create(:user, email: "johndoe@example.com")

    page.driver.browser.authorize("admin", "password")
    visit admin_users_path

    click_link("johndoe@example.com")

    expect(page).to have_content("johndoe@example.com")
  end
end
