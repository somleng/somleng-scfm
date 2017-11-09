class CalloutPopulationEvent < ResourceEvent
  private

  def valid_events
    super && ["queue", "requeue"]
  end
end
