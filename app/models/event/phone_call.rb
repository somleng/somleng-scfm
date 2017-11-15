class Event::PhoneCall < Event::Base
  private

  def valid_events
    super & ["queue", "queue_remote_fetch"]
  end
end
