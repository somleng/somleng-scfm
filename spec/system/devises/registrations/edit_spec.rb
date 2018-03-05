require 'rails_helper'

RSpec.describe 'Change password', type: :system do
  let(:user) { create(:user, password: '12345678') }
  before do
    sign_in(user)
  end

  it 'will change user password' do
    visit '/users/edit'
    fill_in 'user[password]', with: 'helloworld'
    fill_in 'user[password_confirmation]', with: 'helloworld'
    fill_in 'user[current_password]', with: '12345678'
    click_button 'Save'

    expect(page).to have_text('Your account has been updated successfully.')
  end
end
