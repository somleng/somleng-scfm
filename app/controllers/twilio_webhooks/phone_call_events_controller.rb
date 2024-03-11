module TwilioWebhooks
  class PhoneCallEventsController < ApplicationController
    respond_to :xml

    def create
      schema = RemotePhoneCallEventRequestSchema.new(input_params: request.request_parameters)
      result = HandlePhoneCallEvent.call(request.original_url, schema.output)
      respond_with(result, location: nil)
    end
  end
end
