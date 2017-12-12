class Api::CalloutEventsController < Api::ResourceEventsController
  private

  def parent
    callout
  end

  def path_to_parent
    api_callout_path(callout)
  end

  def callout
    @callout ||= current_account.callouts.find(params[:callout_id])
  end

  def event_class
    Event::Callout
  end
end
