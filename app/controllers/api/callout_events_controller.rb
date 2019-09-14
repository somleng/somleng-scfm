module API
  class CalloutEventsController < API::ResourceEventsController
    private

    def parent_resource
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

    def access_token_write_permissions
      [:callouts_write]
    end
  end
end
