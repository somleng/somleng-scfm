require "rails_helper"

RSpec.describe Preview::PhoneCallEventOperation do
  describe "#phone_calls" do
    it "can preview phone calls for BatchOperation::PhoneCallQueue" do
      account = create(:account)
      phone_call_status = PhoneCall::STATE_CREATED

      phone_call, other_phone_call = create_phone_calls(
        account: account,
        status: phone_call_status
      )

      batch_operation = create_batch_operation(
        factory: :phone_call_queue_batch_operation,
        account: account,
        phone_call_filter_status: phone_call_status
      )

      preview = described_class.new(previewable: batch_operation)

      expect(preview.phone_calls(scope: PhoneCall)).to match_array([phone_call, other_phone_call])
      expect(preview.phone_calls(scope: account.phone_calls)).to match_array([phone_call])
    end

    it "can preview phone calls for BatchOperation::PhoneCallQueueRemoteFetch" do
      account = create(:account)
      phone_call_status = PhoneCall::STATE_CREATED

      phone_call, other_phone_call = create_phone_calls(
        account: account,
        status: phone_call_status
      )

      batch_operation = create_batch_operation(
        factory: :phone_call_queue_remote_fetch_batch_operation,
        account: account,
        phone_call_filter_status: phone_call_status
      )

      preview = described_class.new(previewable: batch_operation)

      expect(preview.phone_calls(scope: PhoneCall)).to match_array([phone_call, other_phone_call])
      expect(preview.phone_calls(scope: account.phone_calls)).to match_array([phone_call])
    end

    def create_batch_operation(factory:, account:, phone_call_filter_status:)
      create(
        factory,
        account: account,
        phone_call_filter_params: {
          status: phone_call_filter_status
        }
      )
    end

    def create_phone_calls(account:, status:)
      phone_call = create_phone_call(
        account: account,
        status: status
      )

      other_phone_call = create(:phone_call, status: status)

      _non_matching_phone_call = create_phone_call(
        account: account,
        status: PhoneCall::STATE_QUEUED
      )

      [phone_call, other_phone_call]
    end
  end
end
