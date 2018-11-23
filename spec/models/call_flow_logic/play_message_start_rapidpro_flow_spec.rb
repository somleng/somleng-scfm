require "rails_helper"

RSpec.describe CallFlowLogic::PlayMessageStartRapidproFlow do
  it_behaves_like("call_flow_logic")

  describe "#run!" do
    it "completes the call and enqueues the StartRapidproFlowJob" do
      phone_call = create(:phone_call, :in_progress, remote_status: "completed")
      event = create(:remote_phone_call_event, phone_call: phone_call)
      call_flow_logic = described_class.new(event: event)

      call_flow_logic.run!

      expect(phone_call.reload).to be_completed
      expect(StartRapidproFlowJob).to have_been_enqueued.with(phone_call)
    end

    it "does not enqueue the job if the phone call is not completed" do
      phone_call = create(:phone_call, :in_progress, remote_status: "in-progress")
      event = create(:remote_phone_call_event, phone_call: phone_call)
      call_flow_logic = described_class.new(event: event)

      call_flow_logic.run!

      expect(phone_call.reload).to be_in_progress
      expect(StartRapidproFlowJob).not_to have_been_enqueued
    end
  end
end
