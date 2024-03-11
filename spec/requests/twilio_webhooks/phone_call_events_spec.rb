require "rails_helper"

RSpec.describe "Phone Call Events" do
  it "Creates a phone call event for an inbound call" do
    account = create(:account, :with_twilio_provider)
    request_body = build_request_body(
      account_sid: account.twilio_account_sid,
      direction: "inbound",
      call_status: "in-progress"
    )

    post(
      twilio_webhooks_phone_call_events_url,
      params: request_body,
      headers: build_twilio_signature(
        auth_token: account.twilio_auth_token,
        url: twilio_webhooks_phone_call_events_url,
        request_body: request_body
      )
    )

    expect(response.code).to eq("201")
    expect(RemotePhoneCallEvent.last!).to have_attributes(
      details: request_body.stringify_keys,
      call_flow_logic: CallFlowLogic::HelloWorld.to_s,
      phone_call: have_attributes(
        call_flow_logic: CallFlowLogic::HelloWorld.to_s,
        status: "in_progress",
        remote_call_id: request_body.fetch(:CallSid),
        remote_status: request_body.fetch(:CallStatus),
        remote_direction: request_body.fetch(:Direction),
        contact: have_attributes(
          msisdn: request_body.fetch(:From)
        )
      )
    )
    expect(response.body).to eq(CallFlowLogic::HelloWorld.new.to_xml)
  end

  it "Creates a phone call event for an outbound call" do
    account = create(:account, :with_twilio_provider)
    phone_call = create_phone_call(:remotely_queued, account:)

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
        twilio_webhooks_phone_call_events_url,
        params: request_body,
        headers: build_twilio_signature(
          auth_token: account.twilio_auth_token,
          url: twilio_webhooks_phone_call_events_url,
          request_body: request_body
        )
      )
    end

    expect(response.code).to eq("201")
    created_event = RemotePhoneCallEvent.last!
    expect(created_event).to have_attributes(
      phone_call:,
      call_duration: 87,
      phone_call: have_attributes(
        status: "completed",
        call_flow_logic: CallFlowLogic::HelloWorld.to_s,
        remote_status: request_body.fetch(:CallStatus),
        duration: 87
      )
    )
    expect(response.body).to eq(CallFlowLogic::HelloWorld.new.to_xml)
  end

  it "Handles incorrect signatures" do
    account = create(:account, :with_twilio_provider)
    request_body = build_request_body(account_sid: account.twilio_account_sid)

    post(
      twilio_webhooks_phone_call_events_url,
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
      To: options.fetch(:to) { "1294" },
      Direction: options.fetch(:direction) { "inbound" },
      CallStatus: options.fetch(:call_status) { "ringing" },
      AccountSid: options.fetch(:account_sid),
      CallDuration: options.fetch(:call_duration) { nil },
      ApiVersion: options.fetch(:api_version) { "2010-04-01" },
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
end
