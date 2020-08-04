require "rails_helper"

RSpec.describe QueueRemoteCallJob do
  describe "#perform" do
    it "queues the call remotely" do
      account = create(:account, :with_twilio_provider)
      phone_call = create(
        :phone_call,
        :queued,
        account: account,
        msisdn: "855715100860",
        remote_request_params: {
          "from" => "1234",
          "to" => "dummy",
          "url" => "http://demo.twilio.com/docs/voice.xml",
          "method" => "GET"
        }
      )
      stub_twilio_request(
        response: {
          body: {
            "sid" => "1234",
            "direction" => "outbound-api",
            "status" => "queued"
          }.to_json
        }
      )

      QueueRemoteCallJob.new.perform(phone_call.id)

      expect(WebMock).to have_requested(
        :post,
        "https://api.twilio.com/2010-04-01/Accounts/#{account.twilio_account_sid}/Calls.json"
      ).with(
        body: {
          "From" => "1234",
          "To" => "+855715100860",
          "Url" => "http://demo.twilio.com/docs/voice.xml",
          "Method" => "GET"
        }
      )

      expect(phone_call.reload).to have_attributes(
        remote_status: "queued",
        remote_call_id: "1234",
        remote_direction: "outbound-api",
        status: "remotely_queued"
      )
    end

    it "handles remote errors" do
      account = create(:account, :with_twilio_provider)
      phone_call = create(:phone_call, :queued, account: account)
      stub_twilio_request(response: { status: 422 })

      QueueRemoteCallJob.new.perform(phone_call.id)

      expect(phone_call.reload).to have_attributes(
        remote_error_message: be_present,
        status: "errored"
      )
    end

    def stub_twilio_request(response:)
      stub_request(:post, %r{https://api.twilio.com}).to_return(response)
    end
  end
end
