require 'rails_helper'

RSpec.describe 'User management page', type: :system do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

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
end
