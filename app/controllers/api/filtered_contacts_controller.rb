class Api::FilteredContactsController < Api::FilteredController
  private

  def filter_class
    Filter::Resource::Contact
  end

  def permitted_filter_params_args
    super.prepend(:msisdn)
  end

  def callout_population
    @callout_population ||= CalloutPopulation.find(params[:callout_population_id])
  end
end
