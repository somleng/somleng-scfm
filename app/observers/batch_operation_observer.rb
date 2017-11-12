class BatchOperationObserver < ApplicationObserver
  def batch_operation_queued(batch_operation)
    RunBatchOperationJob.perform_later(batch_operation.id)
  end
end
