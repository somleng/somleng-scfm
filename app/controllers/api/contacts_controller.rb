class Api::ContactsController < Api::FilteredContactsController
  private

  def find_resources_association_chain
    if params[:callout_population_id]
      callout_population.contacts
    else
      association_chain
    end
  end

  def association_chain
    Contact.all
  end

  def permitted_params
    params.permit(:msisdn, :metadata => {})
  end

  def resource_location
    api_contact_path(resource)
  end
end
