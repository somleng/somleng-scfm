class CalloutPopulationObserver < ApplicationObserver
  def callout_population_queued(callout_population)
    PopulateCalloutJob.perform_later(callout_population.id)
  end
end
