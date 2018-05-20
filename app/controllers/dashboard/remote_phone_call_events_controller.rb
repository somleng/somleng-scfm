class Dashboard::RemotePhoneCallEventsController < Dashboard::BaseController
  helper_method :parent_show_path

  private

  def association_chain
    if parent
      parent.remote_phone_call_events
    else
      current_account.remote_phone_call_events
    end
  end

  def parent
    phone_call if phone_call_id
  end

  def phone_call_id
    params[:phone_call_id]
  end

  def phone_call
    @phone_call ||= current_account.phone_calls.find(phone_call_id)
  end

  def parent_show_path
    polymorphic_path([:dashboard, parent]) if parent
  end
end
