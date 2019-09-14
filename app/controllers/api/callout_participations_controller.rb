module API
  class CalloutParticipationsController < API::BaseController
    include BatchOperationResource

    private

    def build_resource_association_chain
      callout.callout_participations
    end

    def find_resources_association_chain
      if params[:callout_id]
        callout.callout_participations
      elsif params[:contact_id]
        contact.callout_participations
      elsif params[:batch_operation_id]
        batch_operation.callout_participations
      else
        association_chain
      end
    end

    def association_chain
      current_account.callout_participations.all
    end

    def filter_class
      Filter::Resource::CalloutParticipation
    end

    def callout
      @callout ||= current_account.callouts.find(params[:callout_id])
    end

    def contact
      @contact ||= current_account.contacts.find(params[:contact_id])
    end

    def batch_operation_scope
      current_account.batch_operations.can_preview_contacts
    end

    def permitted_create_params
      params.permit(:contact_id, :msisdn, :call_flow_logic, metadata: {})
    end

    def permitted_update_params
      params.permit(
        :call_flow_logic, :msisdn,
        :metadata_merge_mode, metadata: {}
      )
    end
  end
end
