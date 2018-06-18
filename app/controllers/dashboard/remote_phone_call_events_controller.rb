class Dashboard::RemotePhoneCallEventsController < Dashboard::BaseController
  private

  def association_chain
    if parent_resource
      parent_resource.remote_phone_call_events
    else
      current_account.remote_phone_call_events
    end
  end

  def parent_resource
    phone_call if phone_call_id
  end

  def phone_call_id
    params[:phone_call_id]
  end

  def phone_call
    @phone_call ||= current_account.phone_calls.find(phone_call_id)
  end
end
