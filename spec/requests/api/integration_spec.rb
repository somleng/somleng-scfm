require 'rails_helper'

RSpec.describe "Batch Operation Integration Specs" do
  include SomlengScfm::SpecHelpers::RequestHelpers
  let(:body) { {} }

  def setup_scenario
    super
    perform_enqueued_jobs { do_request(method, url, body) }
  end

  describe "POST '/api/batch_operations/:batch_operation_id/batch_operation_events'" do
    include SomlengScfm::SpecHelpers::SomlengClientHelpers

    let(:method) { :post }
    let(:batch_operation_factory_attributes) { {} }
    let(:batch_operation) { create(batch_operation_factory, batch_operation_factory_attributes) }
    let(:url) { api_batch_operation_batch_operation_events_path(batch_operation) }
    let(:body) { { :event => :queue } }
    let(:phone_call_factory_attributes) { {} }
    let(:phone_call) { create(:phone_call, phone_call_factory_attributes) }
    let(:asserted_remote_response_body) { remote_response_params.to_json }
    let(:remote_call_id) {  SecureRandom.uuid }

    def remote_response_params
      {
        "sid" => remote_call_id
      }
    end

    def setup_scenario
      phone_call
      do_stub_request
      super
    end

    def assert_create!
      expect(phone_call.reload.status).to eq(asserted_final_status.to_s)
    end

    context "BatchOperation::PhoneCallQueue" do
      let(:batch_operation_factory) { :phone_call_queue_batch_operation }
      let(:asserted_final_status) { PhoneCall::STATE_REMOTELY_QUEUED }

      def asserted_remote_api_endpoint
        super("Calls")
      end

      def do_stub_request
        stub_request(:post, asserted_remote_api_endpoint).to_return(asserted_remote_response)
      end

      def assert_create!
        super
        expect(phone_call.remotely_queued_at).to be_present
      end

      it { assert_create! }
    end

    context "BatchOperation::PhoneCallQueueRemoteFetch" do
      let(:batch_operation_factory) { :phone_call_queue_remote_fetch_batch_operation }

      let(:phone_call_factory_attributes) {
        {
          :status => PhoneCall::STATE_REMOTELY_QUEUED,
          :remotely_queued_at => Time.now,
          :remote_call_id => remote_call_id
        }
      }

      let(:asserted_final_status) { PhoneCall::STATE_IN_PROGRESS }

      def remote_response_params
        super.merge("status" => "in-progress")
      end

      def asserted_remote_api_endpoint
        super("Calls/#{remote_call_id}")
      end

      def do_stub_request
        stub_request(:get, asserted_remote_api_endpoint).to_return(asserted_remote_response)
      end

      it { assert_create! }
    end
  end
end

