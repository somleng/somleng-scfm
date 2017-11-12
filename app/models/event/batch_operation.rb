class Event::BatchOperation < Event::Base
  private

  def valid_events
    super & ["queue", "requeue"]
  end
end
