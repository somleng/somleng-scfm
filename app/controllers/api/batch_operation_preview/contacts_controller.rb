module API
  module BatchOperationPreview
    class ContactsController < API::FilteredContactsController
      private

      def find_resources_association_chain
        batch_operation.contacts_preview
      end
    end
  end
end
