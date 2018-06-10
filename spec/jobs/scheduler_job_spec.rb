require "rails_helper"

RSpec.describe SchedulerJob do
  include_examples("aws_sqs_queue_url")

  let(:url_helpers) { Rails.application.routes.url_helpers }

  describe "#perform" do
    it "queues batch operations via the API" do
      access_token = create(:access_token, permissions: %i[batch_operations_write])

      batch_operation_id = 1
      batch_operations_url = url_helpers.api_batch_operations_url
      batch_operation_events_url = url_helpers.api_batch_operation_batch_operation_events_url(batch_operation_id)
      stub_request(:post, batch_operations_url).to_return(body: { "id" => batch_operation_id }.to_json)
      stub_request(:post, batch_operation_events_url)

      subject.perform

      asserted_headers = { "Authorization" => encode_credentials(access_token: access_token) }
      assert_create_batch_operation!(
        url: batch_operations_url,
        type: "BatchOperation::PhoneCallCreate",
        asserted_headers: asserted_headers
      )
      assert_create_batch_operation!(
        url: batch_operations_url,
        type: "BatchOperation::PhoneCallQueue",
        asserted_headers: asserted_headers
      )
      assert_create_batch_operation!(
        url: batch_operations_url,
        type: "BatchOperation::PhoneCallQueueRemoteFetch",
        asserted_headers: asserted_headers
      )

      expect(
        a_request(:post, batch_operation_events_url).with(
          body: { event: "queue" },
          headers: asserted_headers
        )
      ).to have_been_made.times(3)
    end

    def assert_create_batch_operation!(url:, type:, asserted_headers:)
      expect(
        a_request(:post, url).with(body: { type: type }, headers: asserted_headers)
      ).to have_been_made.times(1)
    end
  end
end
