module Event
  class PhoneCall < Event::Base
    private

    def valid_events
      valid_events = super & %w[queue]
      valid_events << "queue_remote_fetch" if eventable&.may_queue_remote_fetch?
      valid_events
    end

    def fire_event!
      case event
      when "queue_remote_fetch"
        FetchRemoteCallJob.perform_later(eventable.id)
      else
        eventable.aasm.fire!(event.to_sym)
      end
    end
  end
end
