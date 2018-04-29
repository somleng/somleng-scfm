require 'rails_helper'

RSpec.describe 'Forget Password', type: :system do
  let(:user) { create(:user) }

  it 'will send email for reset password' do
    visit '/users/password/new'
    fill_in 'user[email]', with: user.email
    click_button 'Send reset password'

    expect(page).to have_text('You will receive an email with instructions')
  end
end
