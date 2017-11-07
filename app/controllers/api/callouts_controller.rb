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

  def respond_with_create_resource
    respond_with(resource, :location => api_callout_path(resource))
  end
end
