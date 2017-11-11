require 'rails_helper'

RSpec.describe PhoneCallObserver do
  describe "#phone_call_queued(phone_call)" do
    let(:phone_call) { create(:phone_call, :status => PhoneCall::STATE_QUEUED) }
    let(:enqueued_job) { enqueued_jobs.first }

    def setup_scenario
      subject.phone_call_queued(phone_call)
    end

    it {
      expect(enqueued_job[:job]).to eq(QueueRemoteCallJob)
      expect(enqueued_job[:args]).to eq([phone_call.id])
    }
  end
end

