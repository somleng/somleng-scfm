require 'rails_helper'

RSpec.describe "POST '/api/batch_operations/:batch_operation_id/batch_operation_events'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:factory_attributes) { {} }
  let(:batch_operation) { create(:batch_operation, factory_attributes) }
  let(:eventable) { batch_operation }
  let(:url) { api_batch_operation_batch_operation_events_path(eventable) }

  it_behaves_like "api_resource_event" do
    let(:eventable_path) { api_batch_operation_path(eventable) }
    let(:asserted_new_status) { "queued" }
    let(:event) { "queue" }
  end

  context "queuing" do
    let(:body) { {:event => event} }

    let(:factory_attributes) {
      {
        :status => status
      }
    }

    def setup_scenario
      super
      perform_enqueued_jobs { do_request(:post, url, body) }
    end

    def assert_finished!
      expect(batch_operation.reload).to be_finished
    end

    def assert_invalid!
      expect(response.code).to eq("422")
    end

    context "event=queue" do
      let(:event) { "queue" }

      context "invalid request" do
        let(:status) { BatchOperation::Base::STATE_FINISHED }
        it { assert_invalid! }
      end

      context "valid request" do
        let(:status) { BatchOperation::Base::STATE_PREVIEW }
        it { assert_finished! }
      end
    end

    context "event=requeue" do
      let(:status) { BatchOperation::Base::STATE_FINISHED }
      let(:event) { "requeue" }
      it { assert_finished! }
    end
  end
end
