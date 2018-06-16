require "rails_helper"

RSpec.describe AudioFileProcessorJob do
  describe "#perform" do
    it "uploads the callout voice url to a public bucket" do
      callout = create(:callout, audio_file: "test.mp3")
      ActiveStorage::Current.host = "example.com"

      s3 = Aws::S3::Resource.new(stub_responses: true)
      allow(Aws::S3::Resource).to receive(:new).and_return(s3)

      stub_request(:get, /example\.com/).to_return(body: "hello world")

      subject.perform(callout.id)

      callout.reload
      expect(callout.audio_url).to be_present
      expect(callout.audio_url).to include("test.mp3")
    end
  end
end
