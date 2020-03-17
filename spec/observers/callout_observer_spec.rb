require "rails_helper"

RSpec.describe CalloutObserver do
  describe "#callout_committed" do
    it "enqueues audio processing if the audio file changed" do
      callout = create(:callout, audio_file: file_fixture("test.mp3"))

      expect {
        CalloutObserver.new.callout_committed(callout)
      }.to have_enqueued_job(AudioFileProcessorJob).with(callout.id)
    end

    it "does not enqueue audio processing if there's no audio file" do
      callout = create(:callout)

      expect {
        CalloutObserver.new.callout_committed(callout)
      }.not_to have_enqueued_job(AudioFileProcessorJob)
    end

    it "does not enqueue audio processing if the audio file does not change" do
      callout = create(:callout, audio_file: file_fixture("test.mp3"))
      callout = Callout.find(callout.id)

      expect {
        CalloutObserver.new.callout_committed(callout)
      }.not_to have_enqueued_job(AudioFileProcessorJob)
    end
  end
end
