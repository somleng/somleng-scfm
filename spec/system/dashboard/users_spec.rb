require 'rails_helper'

RSpec.describe 'User management pages', type: :system do
  let(:user) { create(:user) }

  before :each do
    sign_in(user)
  end

  describe 'dashboard list users page' do
    it 'show all users from same account' do
      user2 = create(:user, email: 'bopha@somleng.com.kh', account: user.account)
      visit '/dashboard/users'
      expect(page).to have_text(user.email)
      expect(page).to have_text('bopha@somleng.com.kh')
    end

    it 'not show users from other account' do
      user2 = create(:user, email: 'bopha@somleng.com.kh')

      visit '/dashboard/users'

      expect(page).to have_text(user.email)
      expect(page).not_to have_text('bopha@somleng.com.kh')
    end

    it 'click invite, will open new inviation page' do
      visit 'dashboard/users'

      click_button 'Invite user'

      expect(page).to have_text('Send invitation')
      expect(page).to have_current_path(new_user_invitation_path)
    end

    it 'click user email, will open show user detail page' do
      visit 'dashboard/users'

      click_link user.email

      expect(page).to have_text('User detail')
      expect(page).to have_current_path(dashboard_user_url(user))
    end
  end

  describe 'show user detail page' do
    it 'click delete user' do
      user2 = create(:user, account: user.account)

      visit dashboard_user_path(user2)

      click_button 'Delete'

      expect(page).to have_text('User was successfully destroyed.')
    end

    it 'cannot delete current_user' do
      visit dashboard_user_path(user)

      expect(page).not_to have_button('Delete')
    end
  end

  describe 'edit user page' do
    it 'can update user roles' do
      visit edit_dashboard_user_path(user)

      check('Admin')
      click_button('Update User')
      user.reload

      expect(page).to have_text('User was successfully updated.')
      expect(user.roles?(:admin)).to eq true
    end

    it 'display error message when no roles selected' do
      visit edit_dashboard_user_path(user)

      uncheck('Member')
      click_button('Update User')

      expect(page).to have_text("can't be blank")
    end
  end
end
