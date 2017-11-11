class Event::PhoneCall < Event::Base
  private

  def valid_events
    super & ["queue"]
  end
end
