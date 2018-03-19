require 'rails_helper'

RSpec.describe 'Accept invitation', type: :system do
  let(:inviter) { create(:user) }

  it 'user can set password then auto sign in' do
    visit accept_user_invitation_path(invitation_token: raw_token)

    fill_in 'user[password]', with: 'myscret'
    fill_in 'user[password_confirmation]', with: 'myscret'
    click_button 'Save'

    expect(page).to have_text('Your password was set successfully. You are now signed in.')
  end

  private

  def raw_token
    User.invite!(
      { email: 'bophasd@somleng.com', account_id: inviter.account_id },
      inviter
    ).raw_invitation_token
  end
end
