module Dashboard
  class EventsController < Dashboard::BaseController
    private

    def build_resource_from_params
      @resource = event_class.new(permitted_params.merge(eventable: parent_resource))
    end

    def permitted_params
      params.permit(:event)
    end

    def respond_with_created_resource
      respond_with resource, location: -> { request.headers["Referer"] || dashboard_root_path }
    end
  end
end
