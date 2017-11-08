class Api::ResourceEventsController < Api::AuthenticatedController
  respond_to :json

  private

  def respond_with_create_resource
    if resource.errors.any?
      respond_with(resource)
    else
      respond_with(parent, :location => path_to_parent)
    end
  end

  def build_resource
    @resource = event_class.new(permitted_params.merge(:eventable => parent))
  end

  def permitted_params
    params.permit(:event)
  end
end
