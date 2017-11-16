class Api::CalloutParticipationsController < Api::FilteredController
  include BatchOperationResource

  PERMITTED_BATCH_OPERATION_TYPES = [
    "BatchOperation::CalloutPopulation",
    "BatchOperation::PhoneCallCreate"
  ]

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
    CalloutParticipation.all
  end

  def filter_class
    Filter::Resource::CalloutParticipation
  end

  def callout
    @callout ||= Callout.find(params[:callout_id])
  end

  def contact
    @contact ||= Contact.find(params[:contact_id])
  end

  def permitted_batch_operation_types
    PERMITTED_BATCH_OPERATION_TYPES
  end

  def permitted_build_params
    params.permit(:contact_id, :call_flow_logic, :metadata => {})
  end

  def permitted_update_params
    params.permit(:call_flow_logic, :metadata => {})
  end

  def resource_location
    api_callout_participation_path(resource)
  end
end
