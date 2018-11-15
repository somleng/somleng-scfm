require "rails_helper"

RSpec.describe SchedulerJob do
  include_examples("aws_sqs_queue_url")

  describe "#perform" do
    it "queues batch operations" do
      account = create(
        :account,
        :with_twilio_provider,
        settings: {
          "batch_operation_phone_call_create_parameters" => {
            "remote_request_params" => generate(:twilio_request_params)
          }
        }
      )
      _callout_participation = create_callout_participation(account: account)
      stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/#{account.twilio_account_sid}/Calls.json")
      scheduler_job = described_class.new

      perform_enqueued_jobs { scheduler_job.perform }

      expect(account.batch_operations.pluck(:type, :status)).to match_array(
        [
          ["BatchOperation::PhoneCallCreate", BatchOperation::Base::STATE_FINISHED.to_s],
          ["BatchOperation::PhoneCallQueue", BatchOperation::Base::STATE_FINISHED.to_s],
          ["BatchOperation::PhoneCallQueueRemoteFetch", BatchOperation::Base::STATE_FINISHED.to_s]
        ]
      )
    end
  end
end
