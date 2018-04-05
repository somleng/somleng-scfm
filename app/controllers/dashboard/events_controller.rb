class Dashboard::EventsController < Dashboard::BaseController
  def create
    event = event_class.new(permitted_params.merge(:eventable => parent))

    if event.save
      flash[:notice] = 'Event was successfully processed.'
    else
      flash[:alert] = event.errors.full_messages.first
    end

    redirect_back(fallback_location: dashboard_root_path)
  end

  private

  def permitted_params
    params.permit(:event)
  end
end
