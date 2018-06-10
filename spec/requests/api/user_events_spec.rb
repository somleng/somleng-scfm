require "rails_helper"

RSpec.describe "User Events" do
  it "can invite a user" do
    account = create(:account)
    access_token = create_access_token(resource_owner: account)
    user = create(:user, account: account)

    post(
      api_user_user_events_path(user),
      params: { event: "invite" },
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    expect(response.headers["Location"]).to eq(api_user_path(user))
    user.reload
    expect(user.invitation_sent_at).to be_present
  end

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[users_write],
      **options
    )
  end
end
