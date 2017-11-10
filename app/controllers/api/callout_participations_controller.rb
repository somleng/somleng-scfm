class Api::CalloutParticipationsController < Api::FilteredController
  private

  def build_resource_association_chain
    callout.callout_participations
  end

  def find_resources_association_chain
    if params[:callout_id]
      callout.callout_participations
    elsif params[:contact_id]
      contact.callout_participations
    elsif params[:callout_population_id]
      callout_population.callout_participations
    else
      association_chain
    end
  end

  def association_chain
    CalloutParticipation.all
  end

  def filter_class
    Filter::Resource::CalloutParticipation
  end

  def callout
    @callout ||= Callout.find(params[:callout_id])
  end

  def contact
    @contact ||= Contact.find(params[:contact_id])
  end

  def callout_population
    @callout_population ||= CalloutPopulation.find(params[:callout_population_id])
  end

  def permitted_build_params
    params.permit(:contact_id, :metadata => {})
  end

  def permitted_update_params
    params.permit(:metadata => {})
  end

  def resource_location
    api_callout_participation_path(resource)
  end
end
