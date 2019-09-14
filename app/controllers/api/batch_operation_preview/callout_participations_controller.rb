module API
  module BatchOperationPreview
    class CalloutParticipationsController < API::BaseController
      include BatchOperationResource

      private

      def find_resources_association_chain
        batch_operation.callout_participations_preview
      end

      def batch_operation_scope
        current_account.batch_operations.can_preview_callout_participations
      end
    end
  end
end
