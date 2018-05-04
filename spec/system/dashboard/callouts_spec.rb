require 'rails_helper'

RSpec.describe 'Callout pages', type: :system do
  let(:user) { create(:user) }

  describe 'view all callout' do
    it 'should list all callouts of current account' do
      callout = create(:callout, account: user.account)
      other_callout = create(:callout)

      sign_in(user)
      visit dashboard_callouts_path

      expect(page).to has_callout(callout)
      expect(page).not_to has_callout(other_callout)
    end

    it 'can create new callout', js: true do
      sign_in(user)
      visit dashboard_callouts_path

      click_button 'New callout'
      fill_in_callout_informations
      click_button 'Create Callout'

      expect(page).to have_text('Callout was successfully created.')

      callout = Callout.first
      expect(callout.voice.attached?).to eq true
    end
  end

  describe 'callout detail' do
    it 'click edit will open edit page', js: true do
      callout = create(:callout, account: user.account)

      sign_in(user)
      visit dashboard_callout_path(callout)

      expect(page).to has_callout(callout)

      click_button 'Edit'
      fill_in_callout_informations
      click_button 'Update Callout'

      expect(page).to have_text('Callout was successfully updated.')
      expect(callout.voice.attached?).to eq true
    end

    it 'click delete callout then accept alert' do
      callout = create(:callout, account: user.account)

      sign_in(user)
      visit dashboard_callout_path(callout)
      click_button 'Delete'

      expect(page).to have_text('Callout was successfully destroyed.')
    end
  end

  private

  def has_callout(callout)
    have_selector("#callout_#{callout.id}")
  end

  def fill_in_callout_informations
    file_path = Rails.root + 'spec/support/test_files/test.mp3'
    attach_file 'Sound File', file_path
    wait_for_ajax
    select 'Battambang', from: 'Province'
    wait_for_ajax
    select 'Banan', from: 'District'
    wait_for_ajax
    select 'Kantueu Pir', from: 'Commune'
    wait_for_ajax
    select 'Post Kantueu', from: 'Village'
  end
end
