require 'rails_helper'

RSpec.describe 'User invitation', type: :system do
  context 'admin can invite new user' do
    it 'will send an invitation (pending)' do
      admin = create(:user, roles: :admin)

      sign_in(admin)
      visit new_user_invitation_path

      fill_in 'user[email]', with: 'bopha@somleng.com'
      click_button 'Send an invitation'

      expect(page).to have_text('An invitation email has been sent to bopha@somleng.com.')
    end
  end

  context 'user can accept invitation' do
    it 'can set password then auto sign in' do
      user = create(:user)

      visit accept_user_invitation_path(invitation_token: raw_token(user))

      fill_in 'user[password]', with: 'myscret'
      fill_in 'user[password_confirmation]', with: 'myscret'
      click_button 'Save'

      expect(page).to have_text('Your password was set successfully. You are now signed in.')
    end
  end

  private

  def raw_token(inviter)
    User.invite!(
      { email: 'bophasd@somleng.com', account_id: inviter.account_id },
      inviter
    ).raw_invitation_token
  end
end
