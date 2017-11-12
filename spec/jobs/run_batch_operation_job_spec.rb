require 'rails_helper'

RSpec.describe RunBatchOperationJob do
  describe "#perform(batch_operation_id)" do
    let(:batch_operation) {
      create(
        :batch_operation,
        :status => BatchOperation::Base::STATE_QUEUED
      )
    }

    def setup_scenario
      super
      subject.perform(batch_operation.id)
    end

    it { expect(batch_operation.reload).to be_finished }
  end
end
