class Api::FilteredContactsController < Api::FilteredController
  private

  def filter_class
    Filter::Resource::Contact
  end

  def callout_population
    @callout_population ||= BatchOperation::CalloutPopulation.find(params[:callout_population_id])
  end
end
