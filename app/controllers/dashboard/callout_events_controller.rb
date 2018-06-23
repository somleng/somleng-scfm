class Dashboard::CalloutEventsController < Dashboard::EventsController
  private

  def after_create_resource
    populate_callout
  end

  def populate_callout
    return unless parent_resource.running?
    callout_population = parent_resource.callout_population
    return if callout_population.blank?
    return unless callout_population.preview?
    callout_population.subscribe(BatchOperationObserver.new)
    callout_population.queue!
  end

  def parent_resource
    callout
  end

  def callout
    @callout ||= current_account.callouts.find(params[:callout_id])
  end

  def event_class
    Event::Callout
  end
end
