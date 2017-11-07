class Api::ContactsController < Api::FilteredController
  private

  def association_chain
    Contact.all
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
end
