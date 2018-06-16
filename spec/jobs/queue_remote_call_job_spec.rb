require "rails_helper"

RSpec.describe QueueRemoteCallJob do
  include_examples("aws_sqs_queue_url")

  describe "#perform" do
    it "queues the call remotely" do
      phone_call = create_phone_call(account: account)
      response_body = {
        "sid" => "1234",
        "direction" => "outbound-api",
        "status" => "queued"
      }
      stub_twilio_request(
        account: account, response: { body: response_body.to_json }
      )

      subject.perform(phone_call.id)

      phone_call.reload
      assert_request_made!(account: account, phone_call: phone_call)
      expect(phone_call.remote_queue_response).to include(response_body)
      expect(phone_call.remote_status).to eq(response_body.fetch("status"))
      expect(phone_call.remote_call_id).to eq(response_body.fetch("sid"))
      expect(phone_call.remote_direction).to eq(response_body.fetch("direction"))
      expect(phone_call).to be_remotely_queued
    end

    it "handles remote errors" do
      phone_call = create_phone_call(account: account)
      stub_twilio_request(
        account: account, response: { status: 422 }
      )

      subject.perform(phone_call.id)

      phone_call.reload
      assert_request_made!(account: account, phone_call: phone_call)
      expect(phone_call.remote_error_message).to be_present
      expect(phone_call).to be_errored
    end

    let(:account) { create(:account, :with_twilio_provider) }

    def stub_twilio_request(account:, response:)
      stub_request(
        :post,
        "https://api.twilio.com/2010-04-01/Accounts/#{account.twilio_account_sid}/Calls.json"
      ).to_return(response)
    end

    def create_phone_call(account:, **options)
      super(
        account: account,
        status: PhoneCall::STATE_QUEUED,
        remote_request_params: {
          "from" => "1234",
          "to" => "dummy",
          "url" => "http://demo.twilio.com/docs/voice.xml",
          "method" => "GET"
        },
        **options
      )
    end

    def assert_request_made!(account:, phone_call:)
      request = WebMock.requests.last
      authorization = authorization_header(request: request)
      expect(authorization).to eq("#{account.twilio_account_sid}:#{account.twilio_auth_token}")
      actual_request_body = request_body(request: request)
      expect(actual_request_body).to include(
        "From" => phone_call.remote_request_params.fetch("from"),
        "To" => phone_call.msisdn,
        "Url" => phone_call.remote_request_params.fetch("url"),
        "Method" =>  phone_call.remote_request_params.fetch("method")
      )
    end
  end
end
