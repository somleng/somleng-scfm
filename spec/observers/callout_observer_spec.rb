require "rails_helper"

RSpec.describe CalloutObserver do
  describe "#callout_committed" do
    it "should enqueue audio processing if there's an audio file and no audio_url" do
      callout = create(:callout, audio_file: "test.mp3")
      expect { subject.callout_committed(callout) }.to have_enqueued_job(AudioFileProcessorJob).with(callout.id)
    end

    it "should not enqueue the audio processing if there's already a audio_url" do
      callout = create(:callout, audio_file: "test.mp3", audio_url: "https://www.example.com/foo.mp3")
      expect { subject.callout_committed(callout) }.not_to have_enqueued_job(AudioFileProcessorJob)
    end

    it "should not enqeue the audio processing if there's no audio file" do
      callout = create(:callout)
      expect { subject.callout_committed(callout) }.not_to have_enqueued_job(AudioFileProcessorJob)
    end
  end
end
