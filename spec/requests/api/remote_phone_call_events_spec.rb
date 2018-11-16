require "rails_helper"

RSpec.describe "Remote Phone Call Events" do
  it "can fetch all remote phone call events" do
    filtered_event = create_remote_phone_call_event(
      account: account,
      metadata: {
        "foo" => "bar"
      }
    )
    create_remote_phone_call_event(account: account)
    create(:remote_phone_call_event)

    get(
      api_remote_phone_call_events_path(q: { "metadata" => { "foo" => "bar" } }),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(filtered_event.id)
  end

  it "can list remote phone call events for a phone call" do
    event = create_remote_phone_call_event(account: account)
    _other_event = create_remote_phone_call_event(account: account)

    get(
      api_phone_call_remote_phone_call_events_path(event.phone_call),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(event.id)
  end

  it "can list remote phone call events for a callout participation" do
    event = create_remote_phone_call_event(account: account)
    _other_event = create_remote_phone_call_event(account: account)

    get(
      api_callout_participation_remote_phone_call_events_path(event.phone_call.callout_participation),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(event.id)
  end

  it "can list remote phone call events for a callout" do
    event = create_remote_phone_call_event(account: account)
    _other_event = create_remote_phone_call_event(account: account)

    get(
      api_callout_remote_phone_call_events_path(event.callout),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(event.id)
  end

  it "can list remote phone call events for a contact" do
    event = create_remote_phone_call_event(account: account)
    _other_event = create_remote_phone_call_event(account: account)

    get(
      api_contact_remote_phone_call_events_path(event.contact),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(event.id)
  end

  it "can fetch a remote phone call event" do
    remote_phone_call_event = create_remote_phone_call_event(account: account)

    get(
      api_remote_phone_call_event_path(remote_phone_call_event),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_response = JSON.parse(response.body)
    expect(
      account.remote_phone_call_events.find(parsed_response.fetch("id"))
    ).to eq(remote_phone_call_event)
  end

  it "can update a remote phone call event" do
    remote_phone_call_event = create_remote_phone_call_event(
      account: account, metadata: { "bar" => "baz" }
    )

    request_body = {
      metadata: {
        "foo" => "bar"
      },
      metadata_merge_mode: "replace"
    }

    patch(
      api_remote_phone_call_event_path(remote_phone_call_event),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    remote_phone_call_event.reload
    expect(remote_phone_call_event.metadata).to eq(request_body.fetch(:metadata))
  end

  it "can create a remote phone call event for an inbound call" do
    account = create(:account, :with_twilio_provider)

    request_body = build_request_body(
      account_sid: account.twilio_account_sid,
      direction: "inbound",
      call_status: "in-progress"
    )

    post(
      api_remote_phone_call_events_url,
      params: request_body,
      headers: build_twilio_signature(
        auth_token: account.twilio_auth_token,
        url: api_remote_phone_call_events_url,
        request_body: request_body
      )
    )

    expect(response.code).to eq("201")
    expect(response.headers).not_to have_key("Location")
    created_event = RemotePhoneCallEvent.last!
    expect(created_event.details).to eq(request_body)
    expect(created_event.call_flow_logic).to eq(CallFlowLogic::HelloWorld.to_s)
    created_phone_call = created_event.phone_call
    expect(created_phone_call.call_flow_logic).to eq(CallFlowLogic::HelloWorld.to_s)
    expect(created_phone_call.status).to eq(PhoneCall::STATE_IN_PROGRESS.to_s)
    expect(created_phone_call.remote_call_id).to eq(request_body.fetch("CallSid"))
    expect(created_phone_call.remote_status).to eq(request_body.fetch("CallStatus"))
    expect(created_phone_call.remote_direction).to eq(request_body.fetch("Direction"))
    created_contact = created_phone_call.contact
    expect(created_contact.msisdn).to eq(request_body.fetch("From"))
    expect(response.body).to eq(CallFlowLogic::HelloWorld.new.to_xml)
  end

  it "can create a remote phone call event for an outbound call" do
    account = create(:account, :with_twilio_provider)
    phone_call = create_phone_call(:remotely_queued, account: account)

    request_body = build_request_body(
      call_sid: phone_call.remote_call_id,
      account_sid: account.twilio_account_sid,
      direction: "outbound-api",
      call_status: "completed",
      from: "1294",
      to: phone_call.msisdn,
      call_duration: "87"
    )

    post(
      api_remote_phone_call_events_url,
      params: request_body,
      headers: build_twilio_signature(
        auth_token: account.twilio_auth_token,
        url: api_remote_phone_call_events_url,
        request_body: request_body
      )
    )

    expect(response.code).to eq("201")
    created_event = RemotePhoneCallEvent.last!
    expect(created_event.phone_call).to eq(phone_call)
    expect(created_event.call_duration).to eq(87)
    phone_call.reload
    expect(phone_call).to be_completed
    expect(phone_call.call_flow_logic).to eq(CallFlowLogic::HelloWorld.to_s)
    expect(phone_call.remote_status).to eq(request_body.fetch("CallStatus"))
    expect(phone_call.duration).to eq(87)
    expect(response.body).to eq(CallFlowLogic::HelloWorld.new.to_xml)
  end

  it "cannot create a remote phone call event when requesting json" do
    account = create(:account, :with_twilio_provider)
    request_body = build_request_body(account_sid: account.twilio_account_sid)

    url = api_remote_phone_call_events_url(format: :json)

    expect do
      post(
        url,
        params: request_body,
        headers: build_twilio_signature(
          auth_token: account.twilio_auth_token,
          url: url,
          request_body: request_body
        )
      )
    end.to raise_error(ActionController::UnknownFormat)
  end

  it "cannot create a remote phone call event with the wrong signature" do
    account = create(:account, :with_twilio_provider)
    request_body = build_request_body(account_sid: account.twilio_account_sid)

    post(
      api_remote_phone_call_events_path,
      params: request_body,
      headers: {
        "X-Twilio-Signature" => "wrong"
      }
    )

    expect(response.code).to eq("403")
  end

  it "cannot create a remote phone call event with invalid params" do
    account = create(:account, :with_twilio_provider)
    request_body = build_request_body(
      account_sid: account.twilio_account_sid,
      from: "Invalid"
    )

    post(
      api_remote_phone_call_events_url,
      params: request_body,
      headers: build_twilio_signature(
        auth_token: account.twilio_auth_token,
        url: api_remote_phone_call_events_url,
        request_body: request_body
      )
    )

    expect(response.code).to eq("422")
  end

  def build_request_body(options)
    {
      "CallSid" => options.fetch(:call_sid) { SecureRandom.uuid },
      "From" => options.fetch(:from) { "+85510202101" },
      "To" => options.fetch(:to) { "345" },
      "Direction" => options.fetch(:direction) { "inbound" },
      "CallStatus" => options.fetch(:call_status) { "in-progress" },
      "AccountSid" => options.fetch(:account_sid),
      "CallDuration" => options.fetch(:call_duration) { "" }
    }
  end

  def build_twilio_signature(auth_token:, url:, request_body:)
    {
      "X-Twilio-Signature" => Twilio::Security::RequestValidator.new(
        auth_token
      ).build_signature_for(
        url, request_body
      )
    }
  end

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[remote_phone_call_events_read remote_phone_call_events_write],
      **options
    )
  end

  let(:account) { create(:account) }
  let(:access_token) { create_access_token(resource_owner: account) }
end
