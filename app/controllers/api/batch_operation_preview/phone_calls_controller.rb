module API
  module BatchOperationPreview
    class PhoneCallsController < API::BaseController
      include BatchOperationResource

      private

      def find_resources_association_chain
        batch_operation.phone_calls_preview
      end

      def batch_operation_scope
        current_account.batch_operations.can_preview_phone_calls
      end
    end
  end
end
