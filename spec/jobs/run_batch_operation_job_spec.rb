require 'rails_helper'

RSpec.describe RunBatchOperationJob do
  include_examples("aws_sqs_queue_url")

  describe "#perform(batch_operation_id)" do
    it "runs the batch operation" do
      batch_operation = create(:batch_operation, :queued)

      subject.perform(batch_operation.id)

      expect(batch_operation.reload).to be_finished
    end
  end
end
