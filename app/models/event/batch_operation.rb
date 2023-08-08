module Event
  class BatchOperation < Event::Base
    private

    def valid_events
      super & %w[queue]
    end
  end
end
