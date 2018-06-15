class Api::RemotePhoneCallEventsController < Api::FilteredController
  respond_to :xml,  only: :create
  respond_to :json, except: :create

  skip_before_action :doorkeeper_authorize!,
                     :authorize_access_token_for_write!,
                     only: :create

  private

  def build_resource_from_params
    @resource = RemotePhoneCallEvent.new(details: permitted_create_params)
  end

  def prepare_resource_for_create
    subscribe_listeners
    resource.setup!
  end

  def subscribe_listeners
    resource.subscribe(RemotePhoneCallEventObserver.new)
  end

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

  def after_save_resource
    call_flow_logic_instance.run! if resource.persisted?
  end

  def call_flow_logic_instance
    @call_flow_logic_instance ||= call_flow_logic.new(
      event: resource,
      current_url: request.original_url
    )
  end

  def call_flow_logic
    @call_flow_logic ||= resource.call_flow_logic.constantize
  end

  def respond_with_created_resource
    if resource.persisted?
      respond_with(call_flow_logic_instance, location: nil)
    else
      respond_with(resource)
    end
  end

  # https://www.twilio.com/docs/api/twiml/twilio_request
  def permitted_create_params
    params.permit!.except(:action, :controller, :format)
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
