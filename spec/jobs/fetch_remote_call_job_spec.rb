require "rails_helper"

RSpec.describe FetchRemoteCallJob do
  include_examples("aws_sqs_queue_url")

  describe "#perform" do
    it "fetches the remote call" do
      account = create(:account, :with_twilio_provider)
      remote_call_id = SecureRandom.uuid
      phone_call = create_phone_call(
        account: account,
        status: PhoneCall::STATE_REMOTE_FETCH_QUEUED,
        remote_call_id: remote_call_id
      )

      stub_request(
        :get,
        "https://api.twilio.com/2010-04-01/Accounts/#{account.twilio_account_sid}/Calls/#{remote_call_id}.json"
      ).to_return(
        body: { "status" => "completed" }.to_json
      )

      subject.perform(phone_call.id)

      authorization = authorization_header(request: WebMock.requests.last)
      expect(authorization).to eq("#{account.twilio_account_sid}:#{account.twilio_auth_token}")
      phone_call.reload
      expect(phone_call.remote_response["status"]).to eq("completed")
      expect(phone_call).to be_completed
    end
  end
end
