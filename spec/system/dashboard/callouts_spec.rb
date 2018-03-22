require 'rails_helper'

RSpec.describe 'Callout pages', type: :system do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'view all callout' do
    it 'should list all callouts of current account' do
      account_callout = create(:callout, account: user.account)
      other_callout = create(:callout, created_at: 1.hour.ago)

      visit dashboard_callouts_path

      expect(page).to have_text(account_callout.created_at.to_s)
      expect(page).not_to have_text(other_callout.created_at.to_s)
    end

    it 'on click new callout will open new callout page' do
      visit 'dashboard/callouts'

      click_button 'New callout'
      expect(page).to have_current_path(new_dashboard_callout_path)
    end
  end

  describe 'new callout' do
    it 'successfully create new callout' do
      visit new_dashboard_callout_path

      click_button 'Create Callout'

      expect(page).to have_text('Callout was successfully created.')
    end
  end

  describe 'callout detail' do
    it 'show callout detail' do
      callout = create(:callout, account: user.account)

      visit dashboard_callout_path(callout)

      expect(page).to have_text('Callout detail')
    end

    it 'click edit will open edit page' do
      callout = create(:callout, account: user.account)

      visit dashboard_callout_path(callout)
      click_button 'Edit'

      expect(page).to have_current_path(edit_dashboard_callout_path(callout))
    end

    it 'click delete callout then accept alert' do
      callout = create(:callout, account: user.account)

      visit dashboard_callout_path(callout)
      click_button 'Delete'
      expect(page).to have_text('Callout was successfully destroyed.')
    end
  end

  describe 'edit callout' do
    it 'successfully edit callout' do
      callout = create(:callout, account: user.account)

      visit edit_dashboard_callout_path(callout)

      fill_in 'callout[metadata_forms_attributes][0][attr_key]', with: 'address:city'
      fill_in 'callout[metadata_forms_attributes][0][attr_val]', with: 'Phnom Penh'
      click_button 'Update Callout'

      expect(page).to have_text('Callout was successfully updated.')
    end

    it 'on valid, will render the same page with error message' do
      callout = create(:callout, account: user.account)

      visit edit_dashboard_callout_path(callout)

      fill_in 'callout[metadata_forms_attributes][0][attr_key]', with: 'address:city'
      click_button 'Update Callout'

      expect(page).to have_text('Edit callout')
      expect(page).to have_text("can't be blank")
    end
  end
end
