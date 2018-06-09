require "rails_helper"

RSpec.describe "Phone Call Events" do
  it "can queue a phone call" do
    twilio_account_sid = generate(:twilio_account_sid)
    account = create_account(twilio_account_sid: twilio_account_sid)
    access_token = create_access_token(resource_owner: account)
    phone_call = create_phone_call(account: account)
    remote_call_id = SecureRandom.uuid
    stub_request(
      :post,
      "https://api.twilio.com/2010-04-01/Accounts/#{twilio_account_sid}/Calls.json"
    ).to_return(
      body: { "sid" => remote_call_id }.to_json
    )

    perform_enqueued_jobs do
      post(
        api_phone_call_phone_call_events_path(phone_call),
        params: { event: "queue" },
        headers: build_authorization_headers(access_token: access_token)
      )
    end

    expect(response.code).to eq("201")
    expect(response.headers["Location"]).to eq(api_phone_call_path(phone_call))
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.fetch("status")).to eq(PhoneCall::STATE_QUEUED.to_s)
    phone_call.reload
    expect(phone_call).to be_remotely_queued
    expect(phone_call.remote_call_id).to eq(remote_call_id)
    expect(phone_call.remotely_queued_at).to be_present
  end

  it "can queue a remote fetch" do
    twilio_account_sid = generate(:twilio_account_sid)
    account = create_account(twilio_account_sid: twilio_account_sid)
    access_token = create_access_token(resource_owner: account)
    remote_call_id = SecureRandom.uuid
    phone_call = create_phone_call(
      account: account,
      status: PhoneCall::STATE_REMOTELY_QUEUED,
      remote_call_id: remote_call_id
    )

    stub_request(
      :get,
      "https://api.twilio.com/2010-04-01/Accounts/#{twilio_account_sid}/Calls/#{remote_call_id}.json"
    ).to_return(
      body: { "status" => "completed" }.to_json
    )

    perform_enqueued_jobs do
      post(
        api_phone_call_phone_call_events_path(phone_call),
        params: { event: "queue_remote_fetch" },
        headers: build_authorization_headers(access_token: access_token)
      )
    end

    expect(response.code).to eq("201")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.fetch("status")).to eq(PhoneCall::STATE_REMOTE_FETCH_QUEUED.to_s)
    phone_call.reload
    expect(phone_call).to be_completed
  end

  it "cannot queue a call that is already queued" do
    account = create_account
    access_token = create_access_token(resource_owner: account)
    phone_call = create_phone_call(
      account: account,
      status: PhoneCall::STATE_QUEUED
    )

    post(
      api_phone_call_phone_call_events_path(phone_call),
      params: { event: "queue" },
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[phone_calls_write],
      **options
    )
  end

  def create_account(twilio_account_sid: nil, **options)
    create(
      :account,
      platform_provider_name: "twilio",
      twilio_account_sid: twilio_account_sid,
      **options
    )
  end
end
