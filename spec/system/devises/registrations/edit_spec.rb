require 'rails_helper'

RSpec.describe 'Change password', type: :system do
  let(:user) { create(:user) }
  before do
    sign_in(user)
  end

  it 'will change user password' do
    visit '/users/edit'
    fill_in 'user[password]', with: 'new-password'
    fill_in 'user[password_confirmation]', with: 'new-password'
    fill_in 'user[current_password]', with: user.password
    click_button 'Save'

    expect(page).to have_text('Your account has been updated successfully.')
  end
end
