require "rails_helper"

RSpec.describe "Locales" do
  let(:user) { create(:user) }

  it "can update user locale" do
    user = create(:user)

    sign_in(user)
    visit dashboard_root_path

    expect(page).to have_content("Language")

    click_on("Language")
    click_on("ខែ្មរ")

    expect(page).to have_content("តេចេញ")
    user.reload
    expect(user.locale).to eq "km"
  end
end
