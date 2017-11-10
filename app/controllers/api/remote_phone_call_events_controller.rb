class Api::RemotePhoneCallEventsController < Api::BaseController
  respond_to :xml

  private

  def build_resource
    @resource = phone_call.remote_phone_call_events.new(:details => permitted_params)
  end

  def phone_call
    @phone_call ||= find_or_initialize_phone_call
  end

  def find_or_initialize_phone_call
    phone_call = PhoneCall.where(
      :remote_call_id => params["CallSid"],
      :remote_direction => params["Direction"]
    ).first_or_initialize

    phone_call.contact ||= Contact.where(
      :msisdn => params["From"]
    ).first_or_initialize if phone_call.new_record?

    phone_call
  end

  def respond_with_create_resource
    if resource.persisted?
      respond_with(call_flow_logic, :location => nil)
    else
      respond_with(resource)
    end
  end

  def call_flow_logic
    event_call_flow_logic = resource.call_flow_logic
    permitted_call_flow_logic = event_call_flow_logic && CallFlowLogic::Base.descendants.map(&:to_s).select { |available_call_flow_logic| available_call_flow_logic == event_call_flow_logic }.first
    (permitted_call_flow_logic && permitted_call_flow_logic.constantize || default_call_flow_logic).new(resource)
  end

  def default_call_flow_logic
    CallFlowLogic::Application
  end

  # https://www.twilio.com/docs/api/twiml/twilio_request
  def permitted_params
    params.permit(
      "CallSid", "From", "To",
      "CallStatus", "Direction",
      "AccountSid", "ApiVersion", "Digits"
    )
  end
end
