module TwilioWebhooks
  class RecordingStatusCallbacksController < TwilioWebhooksController
    def create
      schema = RecordingStatusCallbackRequestSchema.new(input_params: request.request_parameters)
      ExecuteWorkflowJob.perform_later(HandleRecordingStatusCallback.to_s, schema.output)

      head(:ok)
    end
  end
end
