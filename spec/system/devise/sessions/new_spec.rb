require 'rails_helper'

RSpec.describe 'User sign in', type: :system do
  let(:user) { create(:user, password: 'mysecret') }

  it 'can sign in' do
    visit '/users/sign_in'
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: 'mysecret'
    click_button 'Log in'

    expect(page).to have_text('Signed in successfully.')
  end

  it 'cannot sign in with invalid user info' do
    visit '/users/sign_in'
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: 'wrong-password'
    click_button 'Log in'

    expect(page).to have_text('Invalid Email or password.')
  end
end
