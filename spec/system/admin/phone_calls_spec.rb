require "rails_helper"

RSpec.describe "Admin/Phone Calls" do
  it "List phone calls" do
    create(:phone_call, msisdn: "855716877908")

    page.driver.browser.authorize("admin", "password")
    visit admin_phone_calls_path

    click_link("855716877908")

    expect(page).to have_content("855716877908")
  end
end
