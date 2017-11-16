class Api::RemotePhoneCallEventsController < Api::BaseController
  respond_to :xml

  private

  def build_resource
    @resource = RemotePhoneCallEvent.new(:details => permitted_params)
  end

  def after_save_resource
    call_flow_logic_instance.run! if resource.persisted?
  end

  def call_flow_logic_instance
    @call_flow_logic_instance ||= call_flow_logic.new(:event => resource)
  end

  def call_flow_logic
    @call_flow_logic ||= begin
      resource_call_flow_logic = CallFlowLogic::Base.descendants.map(&:to_s).select { |available_call_flow_logic| available_call_flow_logic == resource.call_flow_logic }.first
      (resource_call_flow_logic && resource_call_flow_logic.constantize) || CallFlowLogic::Application
    end
  end

  def respond_with_create_resource
    if resource.persisted?
      respond_with(call_flow_logic_instance, :location => nil)
    else
      respond_with(resource)
    end
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
