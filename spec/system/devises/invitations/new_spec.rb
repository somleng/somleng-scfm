require 'rails_helper'

RSpec.describe 'Send invitation', type: :system do
  let(:user) { create(:user, password: '12345678') }
  before do
    sign_in(user)
  end

  it 'will send an invitation (pending)' do
    # visit '/users/invitation/new'
    # fill_in 'user[email]', with: 'bopha@somleng.com'
    # click_button 'Send an invitation'
    #
    # expect(page).to have_text('sent an invitation successfully.')
  end
end
