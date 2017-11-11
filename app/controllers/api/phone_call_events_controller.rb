class Api::PhoneCallEventsController < Api::ResourceEventsController
  private

  def setup_resource
    subscribe_listeners
  end

  def subscribe_listeners
    phone_call.subscribe(PhoneCallObserver.new)
  end

  def parent
    phone_call
  end

  def phone_call
    @phone_call ||= PhoneCall.find(params[:phone_call_id])
  end

  def path_to_parent
    api_phone_call_path(phone_call)
  end

  def event_class
    Event::PhoneCall
  end
end
