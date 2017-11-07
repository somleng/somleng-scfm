class Api::CalloutsController < Api::FilteredController
  private

  def association_chain
    Callout.all
  end

  def filter_class
    CalloutFilter
  end

  def permitted_filter_params_args
    super.prepend(:status)
  end

  def permitted_params
    params.permit(:metadata => {})
  end

  def resource_location
    api_callout_path(resource)
  end
end
