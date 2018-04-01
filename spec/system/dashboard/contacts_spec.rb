require 'rails_helper'

RSpec.describe 'Contact pages', type: :system do
  let(:user) { create(:user) }
  let(:admin) { create(:user, roles: :admin) }

  describe 'view all contacts' do
    it 'should list all contacts of current account' do
      account_contact = create(:contact, account: user.account)
      other_contact = create(:contact)

      sign_in user
      visit dashboard_contacts_path

      expect(page).to have_text(account_contact.msisdn)
      expect(page).not_to have_text(other_contact.msisdn)
    end

    it 'on click new contact will open new contact page' do
      sign_in admin
      visit dashboard_contacts_path

      click_button 'New contact'
      expect(page).to have_current_path(new_dashboard_contact_path)
    end
  end

  describe 'new contact' do
    it 'successfully create new contact' do
      sign_in admin
      visit new_dashboard_contact_path

      fill_in 'contact[msisdn]', with: generate(:somali_msisdn)
      click_button 'Create Contact'

      expect(page).to have_text('Contact was successfully created.')
    end

    it 'on valid, will render the same page with error message' do
      sign_in admin
      visit new_dashboard_contact_path

      fill_in 'contact[msisdn]', with: ''
      click_button 'Create Contact'

      expect(page).to have_text('New contact')
      expect(page).to have_text("can't be blank")
    end

    it 'only admin can create new contact' do
      sign_in user

      visit new_dashboard_contact_path
      expect(page).to have_text("We're sorry, but you do not have permission to view this page.")
    end
  end

  describe 'contact detail' do
    it 'show contact detail' do
      contact = create(:contact, account: user.account)

      sign_in user
      visit dashboard_contact_path(contact)

      expect(page).to have_text('Contact detail')
    end

    it 'click edit will open edit page' do
      contact = create(:contact, account: admin.account)

      sign_in admin
      visit dashboard_contact_path(contact)
      click_button 'Edit'

      expect(page).to have_current_path(edit_dashboard_contact_path(contact))
    end

    it 'click delete contact then accept alert' do
      contact = create(:contact, account: admin.account)

      sign_in admin
      visit dashboard_contact_path(contact)
      click_button 'Delete'
      expect(page).to have_text('Contact was successfully destroyed.')
    end
  end

  describe 'edit contact' do
    it 'successfully edit contact' do
      contact = create(:contact, account: admin.account)

      sign_in admin
      visit edit_dashboard_contact_path(contact)

      fill_in 'contact[msisdn]', with: generate(:somali_msisdn)
      click_button 'Update Contact'

      expect(page).to have_text('Contact was successfully updated.')
    end

    it 'on valid, will render the same page with error message' do
      contact = create(:contact, account: admin.account)

      sign_in admin
      visit edit_dashboard_contact_path(contact)

      fill_in 'contact[msisdn]', with: ''
      click_button 'Update Contact'

      expect(page).to have_text('Edit contact')
      expect(page).to have_text("can't be blank")
    end

    it 'only admin can create new contact' do
      contact = create(:contact, account: user.account)

      sign_in user
      visit edit_dashboard_contact_path(contact)

      expect(page).to have_text("We're sorry, but you do not have permission to view this page.")
    end
  end
end
