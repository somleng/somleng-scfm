require "rails_helper"

RSpec.describe "Admin/Callouts" do
  it "List callouts" do
    callout = create(:callout)

    page.driver.browser.authorize("admin", "password")
    visit admin_callouts_path

    click_link(callout.id.to_s)

    expect(page).to have_content(callout.id)
  end
end
