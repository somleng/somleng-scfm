class Dashboard::EventsController < Dashboard::BaseController
  def create
    event = event_class.new(permitted_params.merge(eventable: parent))
    event.save
    respond_with event, location: -> { request.headers["Referer"] || dashboard_root_path }
  end

  private

  def permitted_params
    params.permit(:event)
  end
end
