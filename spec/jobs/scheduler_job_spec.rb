require "rails_helper"

RSpec.describe SchedulerJob do
  include_examples("aws_sqs_queue_url")

  let(:url_helpers) { Rails.application.routes.url_helpers }

  describe "#perform" do
    it "creates a batch operation via the API" do
      _access_token = create(:access_token, permissions: %i[batch_operations_write])

      batch_operation_id = 1
      batch_operations_url = url_helpers.api_batch_operations_url
      batch_operation_events_url = url_helpers.api_batch_operation_batch_operation_events_url(batch_operation_id)
      stub_request(:post, batch_operations_url).to_return(body: { "id" => batch_operation_id }.to_json)
      stub_request(:post, batch_operation_events_url)

      subject.perform

      expect(a_request(:post, batch_operations_url).with(body: { type: "BatchOperation::PhoneCallCreate" } )).to have_been_made
      expect(a_request(:post, batch_operations_url).with(body: { type: "BatchOperation::PhoneCallQueue" } )).to have_been_made
      expect(a_request(:post, batch_operations_url).with(body: { type: "BatchOperation::PhoneCallQueueRemoteFetch" } )).to have_been_made
      expect(a_request(:post, batch_operation_events_url).with(body: { event: "queue" })).to have_been_made.times(3)
    end
  end
end
