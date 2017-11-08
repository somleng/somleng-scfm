class Api::ContactsController < Api::FilteredContactsController
  private

  def association_chain
    if params[:callout_population_id]
      callout_population.contacts
    else
      Contact.all
    end
  end

  def permitted_params
    params.permit(:msisdn, :metadata => {})
  end

  def resource_location
    api_contact_path(resource)
  end
end
