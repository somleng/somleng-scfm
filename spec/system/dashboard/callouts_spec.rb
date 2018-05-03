require "rails_helper"

RSpec.describe "Callout pages", type: :system do
  let(:user) { create(:user) }

  describe "view all callout" do
    it "should list all callouts of current account" do
      callout = create(:callout, account: user.account)
      other_callout = create(:callout)

      sign_in(user)
      visit dashboard_callouts_path

      expect(page).to has_callout(callout)
      expect(page).not_to has_callout(other_callout)
    end

    it "can create a callout" do
      sign_in(user)
      visit dashboard_callouts_path

      click_button "New Callout"
      click_button "Create Callout"

      expect(page).to have_text("Callout was successfully created.")
    end
  end

  describe "callout detail" do
    it "click edit will open edit page" do
      callout = create(:callout, account: user.account)

      sign_in(user)
      visit dashboard_callout_path(callout)

      expect(page).to has_callout(callout)

      click_button "Edit"
      click_button "Update Callout"

      expect(page).to have_text("Callout was successfully updated.")
    end

    it "click delete callout then accept alert" do
      callout = create(:callout, account: user.account)

      sign_in(user)
      visit dashboard_callout_path(callout)
      click_button "Delete"

      expect(page).to have_text("Callout was successfully destroyed.")
    end
  end

  private

  def has_callout(callout)
    have_selector("#callout_#{callout.id}")
  end
end
