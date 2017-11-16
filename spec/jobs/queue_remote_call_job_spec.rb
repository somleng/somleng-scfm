require 'rails_helper'

RSpec.describe QueueRemoteCallJob do
  include_examples("application_job")

  describe "#perform(phone_call_id)" do
    include SomlengScfm::SpecHelpers::SomlengClientHelpers

    def remote_request_params
      {
        "from" => "1234",
        "to" => "dummy",
        "url" => "http://demo.twilio.com/docs/voice.xml",
        "method" => "GET"
      }
    end

    def asserted_remote_api_endpoint
      super("Calls")
    end

    let(:phone_call) {
      create(
        :phone_call,
        :status => PhoneCall::STATE_QUEUED,
        :remote_request_params => remote_request_params
      )
    }

    let(:remote_response_params) {
      {
        "sid" => "1234",
        "direction" => "outbound-api",
        "status" => "queued"
      }
    }

    let(:asserted_remote_response_body) { remote_response_params.to_json }
    let(:assert_remote_request) { true }

    def setup_scenario
      super
      stub_request(:post, asserted_remote_api_endpoint).to_return(asserted_remote_response)
      subject.perform(phone_call.id)
    end

    def assert_perform!
      assert_somleng_client_request!
      request = client_requests.first
      request_body = client_request_body(request)
      expect(request_body).to include(
        "From" => remote_request_params["from"],
        "To" => phone_call.msisdn,
        "Url" => remote_request_params["url"],
        "Method" => remote_request_params["method"]
      )

      expect(phone_call.reload.remote_queue_response).to include(asserted_remote_queue_response)
      expect(phone_call.remote_status).to eq(asserted_remote_status)
      expect(phone_call.remote_call_id).to eq(asserted_remote_call_id)
      expect(phone_call.remote_direction).to eq(asserted_remote_direction)
      expect(phone_call.remote_error_message).to eq(asserted_remote_error_message)
      expect(phone_call.reload.status).to eq(asserted_status)
    end

    context "remote call was enqueued successfully" do
      let(:asserted_remote_response_status) { 200 }
      let(:asserted_status) { "remotely_queued" }
      let(:asserted_remote_queue_response) { remote_response_params }
      let(:asserted_remote_call_id) { remote_response_params["sid"] }
      let(:asserted_remote_direction) { remote_response_params["direction"] }
      let(:asserted_remote_status) { remote_response_params["status"] }
      let(:asserted_remote_error_message) { nil }
      it { assert_perform! }
    end

    context "call was not enqueued successfully" do
      let(:asserted_status) { "errored" }
      let(:asserted_remote_call_id) { nil }
      let(:asserted_remote_direction) { nil }
      let(:asserted_remote_status) { nil }
      let(:asserted_remote_queue_response) { {} }
      let(:asserted_remote_response_status) { 422 }
      let(:asserted_remote_error_message) { "Unable to create record" }
      it { assert_perform! }
    end
  end
end
