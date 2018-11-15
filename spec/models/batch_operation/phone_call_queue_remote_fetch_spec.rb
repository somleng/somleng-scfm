require "rails_helper"

RSpec.describe BatchOperation::PhoneCallQueueRemoteFetch do
  let(:factory) { :phone_call_queue_remote_fetch_batch_operation }

  include_examples("batch_operation")
  include_examples("phone_call_operation_batch_operation")
  include_examples("phone_call_event_operation_batch_operation")

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

  describe "#run!" do
    it "queues a job to fetch the remote status" do
      batch_operation = create(:phone_call_queue_remote_fetch_batch_operation)
      phone_call = create_phone_call(:remotely_queued, account: batch_operation.account)

      expect { batch_operation.run! }.to have_enqueued_job(FetchRemoteCallJob)

      expect(batch_operation.reload.phone_calls).to match_array([phone_call])
    end
  end
end
