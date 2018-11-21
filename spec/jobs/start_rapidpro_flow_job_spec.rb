require "rails_helper"

RSpec.describe StartRapidproFlowJob do
  include_examples("aws_sqs_queue_url")

  describe "#perform" do
    it "calls the StartRapidproFlow workflow" do
      phone_call = create(:phone_call)
      job = described_class.new
      workflow = stub_workflow

      job.perform(phone_call)

      expect(StartRapidproFlow).to have_received(:new).with(phone_call)
      expect(workflow).to have_received(:call)
    end
  end

  def stub_workflow
    flow = instance_spy(StartRapidproFlow)
    allow(StartRapidproFlow).to receive(:new).and_return(flow)
    flow
  end
end
