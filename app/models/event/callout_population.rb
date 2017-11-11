class Event::CalloutPopulation < Event::Base
  private

  def valid_events
    super & ["queue", "requeue"]
  end
end
