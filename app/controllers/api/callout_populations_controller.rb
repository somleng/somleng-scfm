class Api::CalloutPopulationsController < Api::FilteredController
  respond_to :json

  private

  def build_resource
    @resource = callout.callout_populations.new(permitted_params)
  end

  def filter_class
    Filter::Resource::CalloutPopulation
  end

  def build_resource_association_chain
    callout.callout_populations
  end

  def find_resource_association_chain
    CalloutPopulation.all
  end

  def find_resources_association_chain
    if params[:callout_id]
      callout.callout_populations
    else
      CalloutPopulation.all
    end
  end

  def callout
    @callout ||= Callout.find(params[:callout_id])
  end

  def permitted_params
    params.permit(:metadata => {}, :contact_filter_params => {})
  end

  def resource_location
    api_callout_population_path(resource)
  end
end
