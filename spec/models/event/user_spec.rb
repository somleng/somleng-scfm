require "rails_helper"

RSpec.describe Event::User do
  let(:eventable_factory) { :user }

  it_behaves_like("resource_event", assert_status: false) do
    let(:event) { "invite" }
  end

  describe "#save" do
    it "queues a job for sending the invite" do
      user = create(:user)
      user_event = build_event(user, "invite")

      user_event.save

      enqueued_job = enqueued_jobs.first
      expect(enqueued_job).to be_present
      expect(enqueued_job[:job]).to eq(ActionMailer::DeliveryJob)
      expect(enqueued_job[:queue]).to eq("queue_name")
    end
  end

  def build_event(eventable, event)
    described_class.new(eventable: eventable, event: event)
  end
end
