require 'rails_helper'

RSpec.describe FetchRemoteCallJob do
  include_examples("application_job")

  describe "#perform(phone_call_id)" do
    include SomlengScfm::SpecHelpers::SomlengClientHelpers

    let(:remote_call_id) { "call-sid" }
    let(:phone_call) {
      create(
        :phone_call,
        :status => PhoneCall::STATE_REMOTE_FETCH_QUEUED,
        :remote_call_id => remote_call_id
      )
    }

    def asserted_remote_api_endpoint
      super("Calls/#{remote_call_id}")
    end

    let(:asserted_remote_response_body) { { "status" => "completed" }.to_json }
    let(:asserted_status) { "completed" }

    def setup_scenario
      super
      stub_request(:get, asserted_remote_api_endpoint).to_return(asserted_remote_response)
      phone_call
      subject.perform(phone_call.id)
    end

    def assert_perform!
      assert_somleng_client_request!
      phone_call.reload
      expect(phone_call.remote_response["status"]).to eq(asserted_status)
      expect(phone_call.status).to eq(asserted_status)
    end

    it { assert_perform! }
  end
end
