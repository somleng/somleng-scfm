require "rails_helper"

RSpec.describe FetchRemoteCallJob do
  describe "#perform" do
    it "updates the remote status of the call" do
      account = create(:account, :with_twilio_provider)
      phone_call = create_phone_call(:in_progress, account: account)
      stub_twilio_request(
        account: account,
        phone_call: phone_call,
        response: { body: { "status" => "in-progress" }.to_json }
      )
      job = described_class.new

      job.perform(phone_call.id)

      phone_call.reload
      assert_request_made!(account: account)
      expect(phone_call.remote_response).to be_present
      expect(phone_call.remote_status).to eq("in-progress")
      expect(phone_call).to be_in_progress
    end

    it "completes a call" do
      account = create(:account, :with_twilio_provider)
      phone_call = create_phone_call(:in_progress, account: account)
      stub_twilio_request(
        account: account,
        phone_call: phone_call,
        response: { body: { "status" => "completed", "duration" => "87" }.to_json }
      )
      job = described_class.new

      job.perform(phone_call.id)

      phone_call.reload
      expect(phone_call.remote_response).to be_present
      expect(phone_call.duration).to eq(87)
      expect(phone_call).to be_completed
    end

    it "returns if there is no remote call id" do
      account = create(:account)
      phone_call = create_phone_call(:created, account: account)
      job = described_class.new

      job.perform(phone_call.id)

      expect(phone_call).to be_created
    end

    def assert_request_made!(account:)
      authorization = authorization_header(request: WebMock.requests.last)
      expect(authorization).to eq("#{account.twilio_account_sid}:#{account.twilio_auth_token}")
    end

    def stub_twilio_request(account:, phone_call:, response:)
      stub_request(
        :get,
        "https://api.twilio.com/2010-04-01/Accounts/#{account.twilio_account_sid}/Calls/#{phone_call.remote_call_id}.json"
      ).to_return(response)
    end
  end
end
