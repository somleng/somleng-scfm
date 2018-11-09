require "rails_helper"

RSpec.describe BatchOperationObserver do
  describe "#batch_operation_queued(callout_population)" do
    it "enqueues the RunBatchOperationJob" do
      batch_operation = create(:batch_operation, :queued)
      batch_opeation_observer = described_class.new

      batch_opeation_observer.batch_operation_queued(batch_operation)

      expect(RunBatchOperationJob).to have_been_enqueued
    end
  end
end
