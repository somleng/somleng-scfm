class Event::BatchOperation < Event::Base
  private

  def valid_events
    super & %w[queue requeue]
  end
end
