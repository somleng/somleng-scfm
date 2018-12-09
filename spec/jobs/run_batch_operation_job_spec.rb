require "rails_helper"

RSpec.describe RunBatchOperationJob do
  describe "#perform(batch_operation_id)" do
    it "runs the batch operation" do
      batch_operation = create(:batch_operation, :queued)
      job = described_class.new

      job.perform(batch_operation.id)

      expect(batch_operation.reload).to be_finished
    end

    # https://www.pivotaltracker.com/story/show/161878803
    it "does not run the batch operation if it's already finished" do
      batch_operation = create(:batch_operation, :finished)
      job = described_class.new

      job.perform(batch_operation.id)

      expect(batch_operation).to be_finished
    end
  end
end
