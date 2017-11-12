class RunBatchOperationJob < ApplicationJob
  attr_accessor :batch_operation_id

  def perform(batch_operation_id)
    self.batch_operation_id = batch_operation_id
    batch_operation.start!
    batch_operation.run!
    batch_operation.finish!
  end

  private

  def batch_operation
    @batch_operation ||= BatchOperation::Base.find(batch_operation_id)
  end
end
