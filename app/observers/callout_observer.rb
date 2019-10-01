class CalloutObserver < ApplicationObserver
  def callout_committed(callout)
    return unless callout.audio_file.attached?
    return unless callout.audio_file_blob_changed?

    AudioFileProcessorJob.perform_later(callout.id)
  end
end
