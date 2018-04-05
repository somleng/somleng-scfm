require 'rails_helper'

RSpec.describe 'Contact pages', type: :system do
  let(:user) { create(:user) }
  let(:admin) { create(:user, roles: :admin) }

  describe 'view all contacts' do
    it 'should list all contacts of current account' do
      contact = create(:contact, account: admin.account)
      other_contact = create(:contact)

      sign_in admin
      visit dashboard_contacts_path

      expect(page).to have_record(contact)
      expect(page).not_to have_record(other_contact)
    end

    it 'can create new contact' do
      sign_in admin
      visit dashboard_contacts_path

      click_button 'New contact'

      fill_in 'contact[msisdn]', with: generate(:somali_msisdn)
      click_button 'Create Contact'

      expect(page).to have_text('Contact was successfully created.')
    end
  end

  describe 'contact detail' do
    it 'show contact detail' do
      contact = create(:contact, account: admin.account)

      sign_in admin
      visit dashboard_contact_path(contact)

      expect(page).to have_record(contact)
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
      visit dashboard_contact_path(contact)
      click_button 'Edit'

      fill_in 'contact[msisdn]', with: generate(:somali_msisdn)
      click_button 'Update Contact'

      expect(page).to have_text('Contact was successfully updated.')
    end
  end
end
