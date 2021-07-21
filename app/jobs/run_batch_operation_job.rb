class RunBatchOperationJob < ApplicationJob
  queue_as Rails.configuration.app_settings.fetch(:aws_sqs_high_priority_queue_name)

  def perform(batch_operation)
    return unless batch_operation.may_start?

    batch_operation.start!
    batch_operation.run!
    batch_operation.finish!
  end
end
