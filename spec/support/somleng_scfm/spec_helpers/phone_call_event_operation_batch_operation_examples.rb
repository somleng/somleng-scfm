RSpec.shared_examples_for("phone_call_event_operation_batch_operation") do
  include_examples("hash_store_accessor", :phone_call_filter_params)

  describe "validations" do
    it "validates presence of phone_calls_preview" do
      batch_operation = create(factory)
      batch_operation.skip_validate_preview_presence = nil

      expect(batch_operation).not_to be_valid
      expect(batch_operation.errors[:phone_calls_preview]).not_to be_empty

      batch_operation.skip_validate_preview_presence = true

      expect(batch_operation).to be_valid

      batch_operation.skip_validate_preview_presence = nil
      create_phone_call(account: batch_operation.account)

      expect(batch_operation).to be_valid
    end
  end

  describe "state_machine" do
    describe "#finish!" do
      it "finishes the batch operation" do
        account = create(:account)
        phone_call = create_phone_call(account: account)

        batch_operation = create(
          factory,
          account: account,
          status: BatchOperation::Base::STATE_RUNNING,
          skip_validate_preview_presence: nil
        )

        phone_call.destroy
        batch_operation.finish!

        expect(batch_operation).to be_finished
      end
    end
  end
end
