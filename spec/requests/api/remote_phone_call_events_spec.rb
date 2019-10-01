require "rails_helper"

RSpec.resource "Remote Phone Call Events" do
  header("Content-Type", "application/json")

  explanation <<~HEREDOC
    Remote Phone Call Events are created by Somleng or Twilio Webhooks,
    when an event happens in a Phone Call. Setup your Somleng or Twilio Webhook endpoint to point to
    `/api/remote_phone_call_events`
  HEREDOC

  get "/api/remote_phone_call_events" do
    example "List all Remote Phone Call Events" do
      filtered_event = create_remote_phone_call_event(
        account: account,
        metadata: {
          "foo" => "bar"
        }
      )
      create_remote_phone_call_event(account: account)
      create(:remote_phone_call_event)

      set_authorization_header(access_token: access_token)
      do_request(q: { "metadata" => { "foo" => "bar" } })

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(filtered_event.id)
    end
  end

  get "/api/phone_calls/:phone_call_id/remote_phone_call_events" do
    example "List remote phone call events for a phone call", document: false do
      event = create_remote_phone_call_event(account: account)
      _other_event = create_remote_phone_call_event(account: account)

      set_authorization_header(access_token: access_token)
      do_request(phone_call_id: event.phone_call.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(event.id)
    end
  end

  get "/api/callout_participations/:callout_participation_id/remote_phone_call_events" do
    example "List remote phone call events for a callout participation", document: false do
      event = create_remote_phone_call_event(account: account)
      _other_event = create_remote_phone_call_event(account: account)

      set_authorization_header(access_token: access_token)
      do_request(callout_participation_id: event.phone_call.callout_participation.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(event.id)
    end
  end

  get "/api/callouts/:callout_id/remote_phone_call_events" do
    example "List remote phone call events for a callout", document: false do
      event = create_remote_phone_call_event(account: account)
      _other_event = create_remote_phone_call_event(account: account)

      set_authorization_header(access_token: access_token)
      do_request(callout_id: event.callout.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(event.id)
    end
  end

  get "/api/contacts/:contact_id/remote_phone_call_events" do
    example "List remote phone call events for a contact", document: false do
      event = create_remote_phone_call_event(account: account)
      _other_event = create_remote_phone_call_event(account: account)

      set_authorization_header(access_token: access_token)
      do_request(contact_id: event.contact.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(event.id)
    end
  end

  get "/api/remote_phone_call_events/:id" do
    example "Retrieve a Remote Phone Call Event" do
      remote_phone_call_event = create_remote_phone_call_event(account: account)

      set_authorization_header(access_token: access_token)
      do_request(id: remote_phone_call_event.id)

      expect(response_status).to eq(200)
      parsed_response = JSON.parse(response_body)
      expect(
        account.remote_phone_call_events.find(parsed_response.fetch("id"))
      ).to eq(remote_phone_call_event)
    end
  end

  patch "/api/remote_phone_call_events/:id" do
    example "Update a Remote Phone Call Event" do
      remote_phone_call_event = create_remote_phone_call_event(
        account: account, metadata: { "bar" => "baz" }
      )

      request_body = {
        metadata: {
          "foo" => "bar"
        },
        metadata_merge_mode: "replace"
      }

      set_authorization_header(access_token: access_token)
      do_request(id: remote_phone_call_event.id, **request_body)

      expect(response_status).to eq(204)
      remote_phone_call_event.reload
      expect(remote_phone_call_event.metadata).to eq(request_body.fetch(:metadata))
    end
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
    expect(created_event.details).to eq(request_body.stringify_keys)
    expect(created_event.call_flow_logic).to eq(CallFlowLogic::HelloWorld.to_s)
    created_phone_call = created_event.phone_call
    expect(created_phone_call.call_flow_logic).to eq(CallFlowLogic::HelloWorld.to_s)
    expect(created_phone_call.status).to eq(PhoneCall::STATE_IN_PROGRESS.to_s)
    expect(created_phone_call.remote_call_id).to eq(request_body.fetch(:CallSid))
    expect(created_phone_call.remote_status).to eq(request_body.fetch(:CallStatus))
    expect(created_phone_call.remote_direction).to eq(request_body.fetch(:Direction))
    created_contact = created_phone_call.contact
    expect(created_contact.msisdn).to eq(request_body.fetch(:From))
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

    perform_enqueued_jobs do
      post(
        api_remote_phone_call_events_url,
        params: request_body,
        headers: build_twilio_signature(
          auth_token: account.twilio_auth_token,
          url: api_remote_phone_call_events_url,
          request_body: request_body
        )
      )
    end

    expect(response.code).to eq("201")
    created_event = RemotePhoneCallEvent.last!
    expect(created_event.phone_call).to eq(phone_call)
    expect(created_event.call_duration).to eq(87)
    phone_call.reload
    expect(phone_call).to be_completed
    expect(phone_call.call_flow_logic).to eq(CallFlowLogic::HelloWorld.to_s)
    expect(phone_call.remote_status).to eq(request_body.fetch(:CallStatus))
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

  def build_request_body(options)
    {
      CallSid: options.fetch(:call_sid) { SecureRandom.uuid },
      From: options.fetch(:from) { "+85510202101" },
      To: options.fetch(:to) { "345" },
      Direction: options.fetch(:direction) { "inbound" },
      CallStatus: options.fetch(:call_status) { "in-progress" },
      AccountSid: options.fetch(:account_sid),
      CallDuration: options.fetch(:call_duration) { nil }
    }.compact
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
