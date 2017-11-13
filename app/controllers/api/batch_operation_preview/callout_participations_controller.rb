class Api::BatchOperationPreview::CalloutParticipationsController < Api::FilteredController
  include BatchOperationResource

  PERMITTED_BATCH_OPERATION_TYPES = [
    "BatchOperation::PhoneCallCreate"
  ]

  private

  def find_resources_association_chain
    batch_operation.preview.callout_participations
  end

  def permitted_batch_operation_types
    PERMITTED_BATCH_OPERATION_TYPES
  end
end
