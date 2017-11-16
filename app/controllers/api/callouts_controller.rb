class Api::CalloutsController < Api::FilteredController
  private

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
end
