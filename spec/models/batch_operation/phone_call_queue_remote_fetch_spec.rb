require "rails_helper"

RSpec.describe BatchOperation::PhoneCallQueueRemoteFetch do
  let(:factory) { :phone_call_queue_remote_fetch_batch_operation }

  include_examples("batch_operation")
  include_examples("phone_call_operation_batch_operation")
  include_examples("phone_call_event_operation_batch_operation") do
    let(:phone_call_factory_attributes) do
      {
        status: PhoneCall::STATE_REMOTELY_QUEUED,
        remote_call_id: SecureRandom.uuid
      }
    end
    let(:asserted_status_after_run) { PhoneCall::STATE_REMOTE_FETCH_QUEUED }
    let(:invalid_transition_status) { PhoneCall::STATE_CREATED }
  end

  describe "#parameters" do
    it "can set the parameters from the account settings" do
      account = build_stubbed(
        :account,
        settings: {
          "batch_operation_phone_call_queue_remote_fetch_parameters" => {
            "phone_call_filter_params" => {
              "status" => "remotely_queued,in_progress"
            }
          }
        }
      )
      batch_operation = described_class.new(account: account)

      batch_operation.valid?

      expect(batch_operation.parameters).to eq(
        account.settings.fetch("batch_operation_phone_call_queue_remote_fetch_parameters")
      )
    end
  end
end
