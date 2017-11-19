class Api::PhoneCallsController < Api::FilteredController
  include BatchOperationResource

  PERMITTED_BATCH_OPERATION_TYPES = [
    "BatchOperation::PhoneCallCreate",
    "BatchOperation::PhoneCallQueue",
    "BatchOperation::PhoneCallQueueRemoteFetch"
  ]

  private

  def find_resources_association_chain
    if params[:callout_participation_id]
      callout_participation.phone_calls
    elsif params[:callout_id]
      callout.phone_calls
    elsif params[:contact_id]
      contact.phone_calls
    elsif params[:batch_operation_id]
      batch_operation.phone_calls
    else
      association_chain
    end
  end

  def build_resource_association_chain
    callout_participation.phone_calls
  end

  def association_chain
    PhoneCall.all
  end

  def permitted_params
    params.permit(:call_flow_logic, :msisdn, :metadata => {}, :remote_request_params => {})
  end

  def resource_location
    api_phone_call_path(resource)
  end

  def filter_class
    Filter::Resource::PhoneCall
  end

  def callout_participation
    @callout_participation ||= CalloutParticipation.find(params[:callout_participation_id])
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
end
