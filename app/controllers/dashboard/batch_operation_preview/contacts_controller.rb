module Dashboard
  module BatchOperationPreview
    class ContactsController < Dashboard::BaseController
      include BatchOperationResource

      private

      def association_chain
        batch_operation.contacts_preview
      end

      def batch_operation_scope
        current_account.batch_operations.can_preview_contacts
      end
    end
  end
end
