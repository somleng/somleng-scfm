class Api::CalloutPopulationEventsController < Api::ResourceEventsController
  private

  def setup_resource
    subscribe_listeners
  end

  def subscribe_listeners
    callout_population.subscribe(CalloutPopulationObserver.new)
  end

  def parent
    callout_population
  end

  def path_to_parent
    api_callout_population_path(callout_population)
  end

  def callout_population
    @callout_population ||= CalloutPopulation.find(params[:callout_population_id])
  end

  def event_class
    CalloutPopulationEvent
  end
end
