module API
  class FilteredContactsController < API::BaseController
    include BatchOperationResource

    private

    def batch_operation_scope
      current_account.batch_operations.can_preview_contacts
    end

    def filter_class
      Filter::Resource::Contact
    end
  end
end
