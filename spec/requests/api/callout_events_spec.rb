require "rails_helper"

RSpec.describe "Callout Events" do
  let(:account) { create(:account) }
  let(:access_token) { create_access_token(resource_owner: account) }

  it "can start a callout" do
    callout = create_callout(
      account: account,
      status: Callout::STATE_INITIALIZED
    )

    request_body = {
      event: "start"
    }

    post(
      api_callout_callout_events_path(callout),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    expect(response.headers["Location"]).to eq(api_callout_path(callout))
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.fetch("status")).to eq("running")
    expect(callout.reload).to be_running
  end

  it "cannot start a running callout" do
    callout = create_callout(
      account: account,
      status: Callout::STATE_RUNNING
    )

    request_body = {
      event: "start"
    }

    post(
      api_callout_callout_events_path(callout),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  def create_callout(account:, **options)
    create(:callout, account: account, **options)
  end

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[callouts_write],
      **options
    )
  end
end
