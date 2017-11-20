class Api::CalloutsController < Api::FilteredController
  private

  def find_resources_association_chain
    if params[:contact_id]
      contact.callouts
    else
      association_chain
    end
  end

  def association_chain
    Callout.all
  end

  def filter_class
    Filter::Resource::Callout
  end

  def permitted_params
    params.permit(:call_flow_logic, :metadata => {})
  end

  def resource_location
    api_callout_path(resource)
  end

  def contact
    @contact ||= Contact.find(params[:contact_id])
  end
end
