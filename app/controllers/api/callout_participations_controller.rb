class Api::CalloutParticipationsController < Api::FilteredController
  private

  def association_chain
    if params[:callout_id]
      callout.callout_participations
    elsif params[:contact_id]
      contact.callout_participations
    elsif params[:callout_population_id]
      callout_population.callout_participations
    else
      CalloutParticipation.all
    end
  end

  def permitted_filter_params_args
    super.prepend(:msisdn)
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
end
