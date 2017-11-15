require 'rails_helper'

RSpec.describe "POST '/api/phone_calls/:phone_call_id/phone_call_events'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:method) { :post }
  let(:factory_attributes) { {} }
  let(:phone_call) { create(:phone_call, factory_attributes) }
  let(:url) { api_phone_call_phone_call_events_path(phone_call) }
  let(:event) { nil }
  let(:body) { { :event => event } }

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

  context "remote requests" do
    include SomlengScfm::SpecHelpers::SomlengClientHelpers
    let(:asserted_remote_response_body) { remote_response_params.to_json }
    let(:remote_call_id) {  SecureRandom.uuid }

    def remote_response_params
      {
        "sid" => remote_call_id
      }
    end

    def setup_scenario
      super
      do_stub_request
      perform_enqueued_jobs { do_request(method, url, body) }
    end

    def assert_created!
      expect(response.code).to eq("201")
      expect(response.headers["Location"]).to eq(api_phone_call_path(phone_call))
      expect(JSON.parse(response.body)["status"]).to eq(asserted_response_status.to_s)
      expect(phone_call.reload.status).to eq(asserted_final_status.to_s)
    end

    context "event=queue_remote_fetch" do
      let(:event) { :queue_remote_fetch }

      let(:factory_attributes) {
        {
          :status => PhoneCall::STATE_REMOTELY_QUEUED,
          :remote_call_id => remote_call_id
        }
      }

      let(:asserted_response_status) { PhoneCall::STATE_REMOTE_FETCH_QUEUED }
      let(:asserted_final_status)    { PhoneCall::STATE_COMPLETED }

      def remote_response_params
        super.merge("status" => "completed")
      end

      def asserted_remote_api_endpoint
        super("Calls/#{remote_call_id}")
      end

      def do_stub_request
        stub_request(:get, asserted_remote_api_endpoint).to_return(asserted_remote_response)
      end

      it { assert_created! }
    end

    context "event=queue" do
      let(:event) { :queue }

      def asserted_remote_api_endpoint
        super("Calls")
      end

      def do_stub_request
        stub_request(:post, asserted_remote_api_endpoint).to_return(asserted_remote_response)
      end

      let(:asserted_response_status) { PhoneCall::STATE_QUEUED }
      let(:asserted_final_status)    { PhoneCall::STATE_REMOTELY_QUEUED }

      def assert_created!
        super
        expect(phone_call.remotely_queued_at).to be_present
      end

      it { assert_created! }
    end
  end
end
