require 'rails_helper'

RSpec.describe 'User management page', type: :system do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe '#index' do
    it 'should list all contacts of current account' do
      account_contact = create(:contact, account: user.account)
      other_contact = create(:contact)

      visit 'dashboard/contacts'

      expect(page).to have_text(account_contact.msisdn)
      expect(page).not_to have_text(other_contact.msisdn)
    end

    it 'on click new contact will open new contact page' do
      visit 'dashboard/contacts'

      click_button 'New contact'
      expect(page).to have_current_path(new_dashboard_contact_path)
    end
  end

  describe '#new' do
    it 'successfully create new contact' do
      visit 'dashboard/contacts/new'

      fill_in 'contact[msisdn]', with: generate(:somali_msisdn)
      click_button 'Create Contact'

      expect(page).to have_text('Contact was successfully created.')
    end

    it 'on valid, will render the same page with error message' do
      visit 'dashboard/contacts/new'

      fill_in 'contact[msisdn]', with: ''
      click_button 'Create Contact'

      expect(page).to have_text('New contact')
      expect(page).to have_text("can't be blank")
    end
  end

  describe '#show' do
    it 'show contact detail' do
      contact = create(:contact, account: user.account)

      visit "dashboard/contacts/#{contact.id}"

      expect(page).to have_text('Contact detail')
      expect(page).to have_button('Back')
      expect(page).to have_button('Edit')
      expect(page).to have_button('Delete')
    end

    it 'click edit will open edit page' do
      contact = create(:contact, account: user.account)

      visit "dashboard/contacts/#{contact.id}"
      click_button 'Edit'

      expect(page).to have_current_path(edit_dashboard_contact_path(contact))
    end

    it 'click delete contact then accept alert' do
      contact = create(:contact, account: user.account)

      visit "dashboard/contacts/#{contact.id}"
      click_button 'Delete'
      expect(page).to have_text('Contact was successfully destroyed.')
    end
  end

  describe '#edit' do
    it 'successfully edit contact' do
      contact = create(:contact, account: user.account)

      visit "dashboard/contacts/#{contact.id}/edit"

      fill_in 'contact[msisdn]', with: generate(:somali_msisdn)
      click_button 'Update Contact'

      expect(page).to have_text('Contact was successfully updated.')
    end

    it 'on valid, will render the same page with error message' do
      contact = create(:contact, account: user.account)

      visit "dashboard/contacts/#{contact.id}/edit"

      fill_in 'contact[msisdn]', with: ''
      click_button 'Update Contact'

      expect(page).to have_text('Edit contact')
      expect(page).to have_text("can't be blank")
    end
  end
end
