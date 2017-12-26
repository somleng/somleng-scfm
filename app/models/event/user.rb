class Event::User < Event::Base
  VALID_EVENTS = ["invite"]

  def save
    if valid?
      case event
      when "invite"
        eventable.invite!
      end
      true
    else
      false
    end
  end

  private

  def valid_events
    eventable && VALID_EVENTS || []
  end
end
