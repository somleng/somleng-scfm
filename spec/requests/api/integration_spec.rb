require 'rails_helper'

RSpec.describe "Integration Specs" do
  include SomlengScfm::SpecHelpers::RequestHelpers
  let(:body) { {} }

  def setup_scenario
    super
    perform_enqueued_jobs { do_request(method, url, body) }
  end

  describe "POST '/api/batch_operations/:batch_operation_id/batch_operation_events'" do
    let(:method) { :post }
    let(:batch_operation_factory_attributes) { {} }
    let(:batch_operation) { create(batch_operation_factory, batch_operation_factory_attributes) }
    let(:url) { api_batch_operation_batch_operation_events_path(batch_operation) }
    let(:body) { { :event => :queue } }

    context "BatchOperation::PhoneCallQueue" do
      include SomlengScfm::SpecHelpers::SomlengClientHelpers

      let(:phone_call) { create(:phone_call) }

      def asserted_remote_api_endpoint
        super("Calls")
      end

      def setup_scenario
        phone_call
        stub_request(:post, asserted_remote_api_endpoint)
        super
      end

      let(:batch_operation_factory) { :phone_call_queue_batch_operation }
      it {
        expect(phone_call.reload.status).to eq(PhoneCall::STATE_ERRORED.to_s)
        expect(phone_call.remotely_queued_at).to be_present
      }
    end
  end
end

