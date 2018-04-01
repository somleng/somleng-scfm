require 'rails_helper'

RSpec.describe 'User management page', type: :system do
  let(:admin) { create(:user, roles: :admin) }

  context "when a user is not an admin tries to users page" do
    let(:user) { create(:user) }

    it 'render page 401' do
      sign_in(user)

      visit dashboard_users_path

      dashboard_root_path
      expect(page).to have_text("We're sorry, but you do not have permission to view this page.")
    end
  end

  describe 'dashboard list users page' do
    before { sign_in(admin) }

    it 'show all users from same account' do
      user = create(:user, email: 'bopha@somleng.com.kh', account: admin.account)

      visit dashboard_users_path

      expect(page).to have_text(user.email)
      expect(page).to have_text('bopha@somleng.com.kh')
    end

    it 'not show users from other account' do
      _user = create(:user, email: 'bopha@somleng.com.kh')

      visit dashboard_users_path

      expect(page).to have_text(admin.email)
      expect(page).not_to have_text('bopha@somleng.com.kh')
    end

    it 'click invite, will open new inviation page' do
      visit dashboard_users_path

      click_button 'Invite user'

      expect(page).to have_text('Send invitation')
      expect(page).to have_current_path(new_user_invitation_path)
    end

    it 'click user email, will open show user detail page' do
      visit dashboard_users_path

      click_link admin.email

      expect(page).to have_text('User detail')
      expect(page).to have_current_path(dashboard_user_url(admin))
    end
  end

  describe 'show user detail page' do
    before { sign_in(admin) }

    it 'click delete user' do
      user = create(:user, account: admin.account)

      visit dashboard_user_path(user)

      click_button 'Delete'

      expect(page).to have_text('User was successfully destroyed.')
    end

    it 'cannot delete current_user' do
      visit dashboard_user_path(admin)

      expect(page).not_to have_button('Delete')
    end
  end

  describe 'edit user page' do
    before { sign_in(admin) }

    it 'can update user roles' do
      visit edit_dashboard_user_path(admin)

      choose('Admin')
      click_button('Update User')
      admin.reload

      expect(page).to have_text('User was successfully updated.')
      expect(admin.roles?(:admin)).to eq true
    end
  end
end
