class CalloutObserver < ApplicationObserver
  def callout_committed(callout)
    return unless callout.audio_file.attached?
    return if callout.audio_url.present?
    AudioFileProcessorJob.perform_later(callout.id)
  end
end
