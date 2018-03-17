require 'rails_helper'

RSpec.describe 'Api key management', type: :system do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  it 'show all api keys of current user account' do
    access_token_1 = create(:access_token, resource_owner: user.account)
    access_token_2 = create(:access_token, resource_owner: user.account)

    visit '/dashboard/access_tokens'

    expect(page).to have_text(access_token_1.token)
    expect(page).to have_text(access_token_2.token)
  end

  it 'not show api keys from other account' do
    access_token = create(:access_token, resource_owner: user.account)
    other_access_token = create(:access_token)

    visit '/dashboard/access_tokens'

    expect(page).to have_text(access_token.token)
    expect(page).not_to have_text(other_access_token.token)
  end
end
