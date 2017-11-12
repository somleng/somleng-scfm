require 'rails_helper'

RSpec.describe BatchOperationObserver do
  describe "#batch_operation_queued(callout_population)" do
    let(:batch_operation) { create(:batch_operation, :status => BatchOperation::Base::STATE_QUEUED) }
    let(:enqueued_job) { enqueued_jobs.first }

    def setup_scenario
      subject.batch_operation_queued(batch_operation)
    end

    it {
      expect(enqueued_job[:job]).to eq(RunBatchOperationJob)
      expect(enqueued_job[:args]).to eq([batch_operation.id])
    }
  end
end

