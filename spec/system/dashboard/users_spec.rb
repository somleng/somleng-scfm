require 'rails_helper'

RSpec.describe 'User management page', type: :system do
  let(:admin) { create(:user, roles: :admin) }

  context "when a user is not an admin tries to users page" do
    let(:user) { create(:user) }

    it 'render page 401' do
      sign_in(user)

      visit dashboard_users_path

      expect(page).to have_text("We're sorry, but you do not have permission to view this page.")
    end
  end

  describe 'dashboard list users page' do
    before { sign_in(admin) }

    it 'show all users from same account' do
      user = create(:user, account: admin.account)
      other_user = create(:user)

      visit dashboard_users_path

      expect(page).to have_record(user)
      expect(page).not_to have_record(other_user)
    end

    it 'click user email, will open show user detail page' do
      visit dashboard_users_path

      click_link admin.email

      expect(page).to have_record(admin)
    end
  end

  describe 'show user detail page' do
    it 'click delete user' do
      user = create(:user, account: admin.account)

      sign_in(admin)
      visit dashboard_user_path(user)

      click_button 'Delete'

      expect(page).to have_text('User was successfully destroyed.')
    end

    it 'can update user roles' do
      user = create(:user, account: admin.account)

      sign_in(admin)
      visit dashboard_user_path(user)

      click_button 'Edit'

      choose('Admin')
      click_button('Update User')
      admin.reload

      expect(page).to have_text('User was successfully updated.')
    end
  end
end
