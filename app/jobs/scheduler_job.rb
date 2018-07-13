class SchedulerJob < ApplicationJob
  def perform
    Account.find_each do |account|
      queue_batch_operation!(account, type: BatchOperation::PhoneCallCreate)
      queue_batch_operation!(account, type: BatchOperation::PhoneCallQueue)
      queue_batch_operation!(account, type: BatchOperation::PhoneCallQueueRemoteFetch)
    end
  end

  private

  def queue_batch_operation!(account, type:)
    batch_operation = type.new(account: account)
    batch_operation.subscribe(BatchOperationObserver.new)
    batch_operation.queue! if batch_operation.save
  end
end
