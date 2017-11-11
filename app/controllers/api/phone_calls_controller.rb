class Api::PhoneCallsController < Api::FilteredController
  private

  def find_resources_association_chain
    if params[:callout_participation_id]
      callout_participation.phone_calls
    elsif params[:callout_id]
      callout.phone_calls
    elsif params[:contact_id]
      contact.phone_calls
    else
      association_chain
    end
  end

  def build_resource_association_chain
    callout_participation.phone_calls
  end

  def association_chain
    PhoneCall.all
  end

  def permitted_params
    params.permit(:metadata => {})
  end

  def resource_location
    api_phone_call_path(resource)
  end

  def filter_class
    Filter::Resource::PhoneCall
  end

  def callout_participation
    @callout_participation ||= CalloutParticipation.find(params[:callout_participation_id])
  end

  def callout
    @callout ||= Callout.find(params[:callout_id])
  end

  def contact
    @contact ||= Contact.find(params[:contact_id])
  end
end
