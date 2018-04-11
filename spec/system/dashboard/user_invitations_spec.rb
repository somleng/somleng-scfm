require 'rails_helper'

RSpec.describe 'User invitation', type: :system do
  context 'admin can invite new user' do
    it 'will send an invitation (pending)' do
      admin = create(:admin)
      account = admin.account

      sign_in(admin)
      visit new_user_invitation_path

      send_invitation(email: 'bopha@somleng.com', roles: 'Admin', location: 'Banteay Meanchey')

      new_user = account.users.find_by(email: 'bopha@somleng.com')

      expect(page).to have_text('An invitation email has been sent to bopha@somleng.com.')
      expect(new_user.roles?(:admin)).to eq true
      expect(new_user.location_ids).to include_location('Banteay Meanchey')
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

  def send_invitation(options = {})
    fill_in 'user[email]', with: options[:email]
    choose options[:roles]
    select options[:location], from: 'Locations'
    click_button 'Send an invitation'
  end
end
