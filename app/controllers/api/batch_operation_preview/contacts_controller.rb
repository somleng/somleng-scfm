class Api::BatchOperationPreview::ContactsController < Api::FilteredContactsController
  private

  def find_resources_association_chain
    batch_operation.contacts_preview
  end
end
