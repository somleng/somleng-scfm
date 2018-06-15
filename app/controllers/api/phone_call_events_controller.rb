class Api::PhoneCallEventsController < Api::ResourceEventsController
  private

  def prepare_resource_for_create
    subscribe_listeners
  end

  def subscribe_listeners
    phone_call.subscribe(PhoneCallObserver.new)
  end

  def parent
    phone_call
  end

  def phone_call
    @phone_call ||= current_account.phone_calls.find(params[:phone_call_id])
  end

  def path_to_parent
    api_phone_call_path(phone_call)
  end

  def event_class
    Event::PhoneCall
  end

  def access_token_write_permissions
    [:phone_calls_write]
  end
end
