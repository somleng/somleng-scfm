require "rails_helper"

RSpec.describe "home" do
  it "has navigation links" do
    visit(root_path)

    expect(page).to have_link(
      I18n.translate!(:"titles.app_name"),
      href: root_path
    )

    within("#top_nav") do
      expect(page).to have_link("About Us", href: "#")
      expect(page).to have_link("Contact", href: "#")
      expect(page).to have_link("Dashboard", href: dashboard_root_path)
    end
  end
end
