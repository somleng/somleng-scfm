require 'rails_helper'

RSpec.describe 'Callout pages', type: :system do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'view all callout' do
    it 'should list all callouts of current account' do
      account_callout = create(:callout, account: user.account, metadata: { title: 'My Callout'})
      other_callout = create(:callout, metadata: { title: 'Other Callout'})

      visit dashboard_callouts_path

      expect(page).to have_text('My Callout')
      expect(page).not_to have_text('Other Callout')
    end
  end

  describe 'new callout' do
    it 'successfully create new callout' do
      visit new_dashboard_callout_path

      click_button 'Create Callout'

      expect(page).to have_text('Callout was successfully created.')
    end

    it 'render new page if failed to create' do
      visit new_dashboard_callout_path

      fill_in 'callout[metadata_forms_attributes][0][attr_key]', with: 'address:city'
      click_button 'Create Callout'

      expect(page).to have_text('New callout')
      expect(page).to have_text("can't be blank")
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

  describe 'callout can start' do
    it 'when successfully start' do
      callout = create(:callout, account: user.account)

      visit dashboard_callout_path(callout)

      click_button 'Start'

      expect(page).to have_text('Callout was successfully started.')
    end

    it 'when already started' do
      callout = create(:callout, account: user.account, status: 'running')

      visit dashboard_callout_path(callout)

      expect(page).not_to have_button('Start')
    end

    it 'callout was already started during session' do
      callout = create(:callout, account: user.account)

      visit dashboard_callout_path(callout)
      callout.start!
      click_button 'Start'

      expect(page).to have_text('Failed to start.')
    end
  end

  describe 'callout can resume' do
    it 'when successfully resume' do
      callout = create(:callout, account: user.account, status: 'stopped')

      visit dashboard_callout_path(callout)

      click_button 'Resume'

      expect(page).to have_text('Callout was successfully resumed.')
    end

    it 'when already running' do
      callout = create(:callout, account: user.account, status: 'running')

      visit dashboard_callout_path(callout)

      expect(page).not_to have_button('Resume')
    end

    it 'callout was already runned during session' do
      callout = create(:callout, account: user.account, status: 'stopped')

      visit dashboard_callout_path(callout)
      callout.resume!
      click_button 'Resume'

      expect(page).to have_text('Failed to resume.')
    end
  end

  describe 'callout can stop' do
    it 'when successfully stop' do
      callout = create(:callout, account: user.account, status: 'running')

      visit dashboard_callout_path(callout)

      click_button 'Stop'

      expect(page).to have_text('Callout was successfully stopped.')
    end

    it 'when is not running' do
      callout = create(:callout, account: user.account)

      visit dashboard_callout_path(callout)

      expect(page).not_to have_button('Stop')
    end

    it 'callout was already stopped during session' do
      callout = create(:callout, account: user.account, status: 'running')

      visit dashboard_callout_path(callout)
      callout.stop!
      click_button 'Stop'

      expect(page).to have_text('Failed to stop.')
    end
  end
end
