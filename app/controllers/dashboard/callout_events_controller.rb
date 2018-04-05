class Dashboard::CalloutEventsController < Dashboard::EventsController
  private

  def parent
    callout
  end

  def callout
    @callout ||= current_account.callouts.find(params[:callout_id])
  end

  def event_class
    Event::Callout
  end
end
