class Api::ContactsController < Api::FilteredContactsController
  private

  def find_resources_association_chain
    if params[:batch_operation_id]
      batch_operation.contacts
    elsif params[:callout_id]
      callout.contacts
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

  def callout
    @callout ||= Callout.find(params[:callout_id])
  end
end
