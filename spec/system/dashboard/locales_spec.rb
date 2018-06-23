require "rails_helper"

RSpec.describe "Locales" do
  let(:user) { create(:admin) }

  it "can update the user's preferred language" do
    sign_in(user)
    visit dashboard_root_path

    within("#language_menu") do
      click_link("ខែ្មរ")
    end

    expect(page).to have_content("សមាជិកទំនាក់ទំនង")
    user.reload
    expect(user.locale).to eq "km"
  end
end
