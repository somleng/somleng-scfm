class Api::ResourceEventsController < Api::BaseController
  private

  def respond_with_created_resource
    if resource.errors.any?
      respond_with(resource)
    else
      respond_with(parent, location: path_to_parent)
    end
  end

  def build_resource_from_params
    @resource = event_class.new(permitted_params.merge(eventable: parent))
  end

  def permitted_params
    params.permit(:event)
  end
end
