require "rails_helper"

RSpec.describe "Recoding Status Callbacks" do
  it "creates a recording" do
    account = create(:account, :with_twilio_provider)
    phone_call = create(:phone_call, account:)

    # https://www.twilio.com/docs/voice/api/recording#recordingstatuscallback

    request_body = build_request_body(
      call_sid: phone_call.remote_call_id,
      account_sid: account.twilio_account_sid
    )

    stub_request(:get, request_body.fetch(:RecordingUrl) + ".mp3").to_return(body: file_fixture("test.mp3"))

    perform_enqueued_jobs do
      post(
        twilio_webhooks_recording_status_callbacks_url,
        params: request_body,
        headers: build_twilio_signature(
          auth_token: account.twilio_auth_token,
          url: twilio_webhooks_recording_status_callbacks_url,
          request_body: request_body
        )
      )
    end

    expect(response.code).to eq("200")
    expect(account.recordings.last).to have_attributes(
      phone_call:,
      account:,
      contact: phone_call.contact,
      audio_file: be_attached,
      external_recording_id: request_body.fetch(:RecordingSid),
      external_recording_url: request_body.fetch(:RecordingUrl),
      duration: request_body.fetch(:RecordingDuration)
    )
  end

  it "cannot create a recording with the wrong signature" do
    account = create(:account, :with_twilio_provider)
    request_body = build_request_body(account_sid: account.twilio_account_sid)

    post(
      twilio_webhooks_recording_status_callbacks_url,
      params: request_body,
      headers: {
        "X-Twilio-Signature" => "wrong"
      }
    )

    expect(response.code).to eq("403")
  end

  def build_request_body(options)
    call_sid = options.fetch(:call_sid) { SecureRandom.uuid }
    account_sid = options.fetch(:account_sid) { SecureRandom.uuid }
    recording_sid = options.fetch(:recording_sid) { SecureRandom.uuid }
    recording_url = options.fetch(:recording_url) { "https://api.somleng.org/2010-04-01/Accounts/#{account_sid}/Calls/#{call_sid}/Recordings/#{recording_sid}" }

    {
      CallSid: call_sid,
      AccountSid: account_sid,
      RecordingSid: recording_sid,
      RecordingUrl: recording_url,
      RecordingStatus: options.fetch(:recording_status) { "completed" },
      RecordingDuration: options.fetch(:recording_duration) { 15 },
      RecordingChannels: options.fetch(:recording_channels) { 1 },
      RecordingStartTime: options.fetch(:recording_start_time) { Time.current.utc.rfc2822 },
      RecordingSource: options.fetch(:recording_source) { "RecordVerb" }
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
end
