class Event::PhoneCall < Event::Base
  private

  def valid_events
    super & %w[queue queue_remote_fetch]
  end

  def fire_event!
    case event
    when "queue_remote_fetch"
      FetchRemoteCallJob.perform_later(phone_call.id)
    else
      eventable.aasm.fire!(event.to_sym)
    end
  end
end
