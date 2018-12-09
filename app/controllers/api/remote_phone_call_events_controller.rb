class Api::RemotePhoneCallEventsController < Api::BaseController
  respond_to :xml,  only: :create
  respond_to :json, except: :create

  skip_before_action :doorkeeper_authorize!,
                     :authorize_access_token_for_write!,
                     only: :create

  def create
    schema_validation_result = RemotePhoneCallEventRequestSchema.call(request.request_parameters)
    if schema_validation_result.success?
      result = HandlePhoneCallEvent.call(request.original_url, schema_validation_result.output)
      respond_with(result, location: nil)
    else
      respond_with(schema_validation_result)
    end
  end

  private

  def find_resources_association_chain
    if params[:phone_call_id]
      phone_call.remote_phone_call_events
    elsif params[:callout_participation_id]
      callout_participation.remote_phone_call_events
    elsif params[:callout_id]
      callout.remote_phone_call_events
    elsif params[:contact_id]
      contact.remote_phone_call_events
    else
      association_chain
    end
  end

  def association_chain
    current_account.remote_phone_call_events.all
  end

  def filter_class
    Filter::Resource::RemotePhoneCallEvent
  end

  def permitted_update_params
    params.permit(:metadata_merge_mode, metadata: {})
  end

  def phone_call
    @phone_call ||= current_account.phone_calls.find(params[:phone_call_id])
  end

  def callout_participation
    @callout_participation ||= current_account.callout_participations.find(params[:callout_participation_id])
  end

  def callout
    @callout ||= current_account.callouts.find(params[:callout_id])
  end

  def contact
    @contact ||= current_account.contacts.find(params[:contact_id])
  end
end
