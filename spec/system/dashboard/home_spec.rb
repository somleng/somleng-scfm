require "rails_helper"

RSpec.describe "home" do
  it "has navigation links" do
    visit(root_path)

    within("#top_nav") do
      expect(page).to have_link(
        I18n.translate!(:"titles.home.index"),
        href: root_path
      )
      expect(page).to have_link(
        I18n.translate!(:"titles.home.about_us"),
        href: about_us_path
      )
      expect(page).to have_link(
        I18n.translate!(:"titles.home.contact"),
        href: contact_path
      )
      expect(page).to have_link(
        I18n.translate!(:"titles.home.dashboard"),
        href: dashboard_root_path
      )
    end
  end
end
