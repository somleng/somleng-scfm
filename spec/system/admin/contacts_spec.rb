require "rails_helper"

RSpec.describe "Admin/Contacts" do
  it "List contacts" do
    contact = create(:contact)

    page.driver.browser.authorize("admin", "password")
    visit admin_contacts_path

    click_link(contact.id.to_s)

    expect(page).to have_content(contact.id)
  end
end
