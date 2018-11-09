require "rails_helper"

RSpec.describe PhoneCallObserver do
  describe "#phone_call_queued(phone_call)" do
    it "enqueues the QueueRemoteCallJob" do
      phone_call = create(:phone_call, :queued)
      phone_call_observer = described_class.new

      phone_call_observer.phone_call_queued(phone_call)

      expect(QueueRemoteCallJob).to have_been_enqueued
    end
  end

  describe "#phone_call_remote_fetch_queued(phone_call)" do
    it "enqueues the FetchRemoteCallJob" do
      phone_call = create(:phone_call, :remote_fetch_queued)
      phone_call_observer = described_class.new

      phone_call_observer.phone_call_remote_fetch_queued(phone_call)

      expect(FetchRemoteCallJob).to have_been_enqueued
    end
  end
end
