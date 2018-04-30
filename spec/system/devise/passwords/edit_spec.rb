require 'rails_helper'

RSpec.describe 'Reset Password', type: :system do
  let(:user) { create(:user) }

  it 'reset password and sign in' do
    token = user.send_reset_password_instructions

    visit edit_user_password_path(reset_password_token: token)

    fill_in 'user[password]', with: '12345678'
    fill_in 'user[password_confirmation]', with: '12345678'
    click_button 'Change my password'

    expect(page).to have_text(
      'Your password has been changed successfully. You are now signed in.'
    )
  end
end
