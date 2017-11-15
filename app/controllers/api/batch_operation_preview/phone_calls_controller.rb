class Api::BatchOperationPreview::PhoneCallsController < Api::FilteredController
  include BatchOperationResource

  PERMITTED_BATCH_OPERATION_TYPES = [
    "BatchOperation::PhoneCallQueue",
    "BatchOperation::PhoneCallQueueRemoteFetch",
  ]

  private

  def find_resources_association_chain
    batch_operation.phone_calls_preview
  end

  def permitted_batch_operation_types
    PERMITTED_BATCH_OPERATION_TYPES
  end
end
