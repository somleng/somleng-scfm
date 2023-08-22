require "rails_helper"

RSpec.describe "Admin/Accounts" do
  it "List accounts" do
    create(:account, metadata: { name: "My Account" })

    page.driver.browser.authorize("admin", "password")
    visit admin_accounts_path

    click_link("My Account")

    expect(page).to have_content("My Account")
  end
end
