class Api::RemotePhoneCallEventsController < Api::FilteredController
  respond_to :xml,  only: :create
  respond_to :json, except: :create

  private

  def build_resource
    @resource = RemotePhoneCallEvent.new(details: permitted_build_params)
  end

  def setup_resource
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
    @call_flow_logic ||= begin
      resource_call_flow_logic = registered_call_flow_logic(resource.call_flow_logic)
      (resource_call_flow_logic&.constantize) || default_call_flow_logic
    end
  end

  def respond_with_create_resource
    if resource.persisted?
      respond_with(call_flow_logic_instance, location: nil)
    else
      respond_with(resource)
    end
  end

  # https://www.twilio.com/docs/api/twiml/twilio_request
  def permitted_build_params
    params.permit!.except(:action, :controller, :format)
  end

  def permitted_update_params
    params.permit(:metadata_merge_mode, metadata: {})
  end

  def api_authenticate?
    super if params[:action] != "create"
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

  def default_call_flow_logic
    CallFlowLogic::HelloWorld
  end

  def registered_call_flow_logic(call_flow_logic)
    if call_flow_logic
      CallFlowLogic::Base.registered.map(&:to_s).detect { |r| r == call_flow_logic }
    end
  end
end
