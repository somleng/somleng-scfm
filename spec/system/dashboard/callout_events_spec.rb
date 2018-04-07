require 'rails_helper'

RSpec.describe 'Callout events', type: :system do
  let(:user) { create(:user) }

  it 'User can start callout' do
    callout = create(:callout, account: user.account)

    sign_in(user)
    visit dashboard_callout_path(callout)

    click_button('Start')
    expect(page).to have_text('Event was successfully processed.')
    expect(page).to have_current_path(dashboard_callout_path(callout))
  end
end
