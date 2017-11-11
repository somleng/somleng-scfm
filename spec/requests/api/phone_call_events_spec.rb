require 'rails_helper'

RSpec.describe "POST '/api/phone_calls/:phone_call_id/phone_call_events'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:method) { :post }
  let(:factory_attributes) { {} }
  let(:phone_call) { create(:phone_call, factory_attributes) }
  let(:url) { api_phone_call_phone_call_events_path(phone_call) }
  let(:event) { nil }
  let(:body) { { :event => event } }

  context "event=queue" do
    include SomlengScfm::SpecHelpers::SomlengClientHelpers

    let(:event) { :queue }

    def asserted_remote_api_endpoint
      super("Calls")
    end

    let(:remote_response_params) {
      {
        "sid" => "1234",
      }
    }

    let(:asserted_remote_response_body) { remote_response_params.to_json }

    def setup_scenario
      super
      stub_request(:post, asserted_remote_api_endpoint).to_return(asserted_remote_response)
      perform_enqueued_jobs { do_request(method, url, body) }
    end

    def assert_created!
      expect(response.code).to eq("201")
      expect(response.headers["Location"]).to eq(api_phone_call_path(phone_call))
      expect(JSON.parse(response.body)["status"]).to eq("queued")
      expect(phone_call.reload).to be_remotely_queued
      expect(phone_call.remotely_queued_at).to be_present
    end

    it { assert_created! }
  end

  context "invalid request" do
    let(:event) { :queue_remote }
    let(:factory_attributes) { {:status => PhoneCall::STATE_QUEUED} }

    def setup_scenario
      super
      do_request(method, url, body)
    end

    def assert_invalid!
      expect(response.code).to eq("422")
    end

    it { assert_invalid! }
  end
end
