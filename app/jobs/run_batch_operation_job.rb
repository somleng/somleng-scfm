class RunBatchOperationJob < ApplicationJob
  def perform(batch_operation_id)
    batch_operation = BatchOperation::Base.find(batch_operation_id)
    return unless batch_operation.may_start?

    batch_operation.start!
    batch_operation.run!
    batch_operation.finish!
  end
end
