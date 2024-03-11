class RecordingStatusCallbackRequestSchema < ApplicationRequestSchema
  params do
    required(:CallSid).filled(:string)
    required(:AccountSid).filled(:string)
    required(:RecordingSid).filled(:string)
    required(:RecordingUrl).filled(:string)
    required(:RecordingStatus).filled(:string)
    required(:RecordingDuration).filled(:string)
  end

  def output
    params = super

    {
      call_sid: params.fetch(:CallSid),
      account_sid: params.fetch(:AccountSid),
      recording_sid: params.fetch(:RecordingSid),
      recording_url: params.fetch(:RecordingUrl),
      recording_status: params.fetch(:RecordingStatus),
      recording_duration: params.fetch(:RecordingDuration)
    }
  end
end
