class Api::BatchOperationsController < Api::FilteredController
  respond_to :json

  PERMITTED_TYPES = [
    "BatchOperation::CalloutPopulation",
    "BatchOperation::PhoneCallCreate"
  ]

  private

  def filter_class
    Filter::Resource::BatchOperation
  end

  def build_resource_association_chain
    nested_resources_association_chain
  end

  def find_resources_association_chain
    nested_resources_association_chain
  end

  def nested_resources_association_chain
    if params[:callout_id]
      association_chain.where(:callout_id => params[:callout_id])
    else
      association_chain
    end
  end

  def association_chain
    (permitted_types.include?(params[:type]) ? params[:type].constantize : BatchOperation::Base).all
  end

  def callout
    @callout ||= Callout.find(params[:callout_id])
  end

  def permitted_types
    PERMITTED_TYPES
  end

  def permitted_params
    params.permit(:metadata => {}, :parameters => {})
  end

  def resource_location
    api_batch_operation_path(resource)
  end
end
