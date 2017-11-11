class Api::CalloutEventsController < Api::ResourceEventsController
  private

  def parent
    callout
  end

  def path_to_parent
    api_callout_path(callout)
  end

  def callout
    @callout ||= Callout.find(params[:callout_id])
  end

  def event_class
    Event::Callout
  end
end
