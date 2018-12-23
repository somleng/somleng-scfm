module Dashboard
  class CalloutEventsController < Dashboard::EventsController
    private

    def parent_resource
      callout
    end

    def callout
      @callout ||= current_account.callouts.find(params[:callout_id])
    end

    def event_class
      Event::Callout
    end
  end
end
