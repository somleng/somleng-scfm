module API
  class ContactsController < FilteredContactsController
    include ValidateSchemaController
    self.request_schema = ContactRequestSchema

    private

    def find_resources_association_chain
      if params[:batch_operation_id]
        batch_operation.contacts
      elsif params[:callout_id]
        callout.contacts
      else
        association_chain
      end
    end

    def association_chain
      current_account.contacts.all
    end

    def permitted_params
      params.permit(:msisdn, :metadata_merge_mode, metadata: {})
    end

    def callout
      @callout ||= current_account.callouts.find(params[:callout_id])
    end
  end
end
