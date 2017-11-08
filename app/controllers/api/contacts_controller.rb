class Api::ContactsController < Api::FilteredController
  private

  def association_chain
    if params[:callout_population_id]
      callout_population.contacts
    else
      Contact.all
    end
  end

  def filter_class
    ContactFilter
  end

  def permitted_filter_params_args
    super.prepend(:msisdn)
  end

  def permitted_params
    params.permit(:msisdn, :metadata => {})
  end

  def resource_location
    api_contact_path(resource)
  end

  def callout_population
    @callout_population ||= CalloutPopulation.find(params[:callout_population_id])
  end
end
