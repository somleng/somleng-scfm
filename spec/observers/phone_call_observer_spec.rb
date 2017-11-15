require 'rails_helper'

RSpec.describe PhoneCallObserver do
  let(:phone_call_factory_attributes) { {:status => status} }
  let(:phone_call) { create(:phone_call, phone_call_factory_attributes) }
  let(:enqueued_job) { enqueued_jobs.first }

  def setup_scenario
    observe_event!
  end

  def assert_observed!
    expect(enqueued_job[:job]).to eq(asserted_job_class)
    expect(enqueued_job[:args]).to eq([phone_call.id])
  end

  describe "#phone_call_queued(phone_call)" do
    let(:status) { PhoneCall::STATE_QUEUED }
    let(:asserted_job_class) { QueueRemoteCallJob }

    def observe_event!
      subject.phone_call_queued(phone_call)
    end

    it { assert_observed! }
  end

  describe "#phone_call_remote_fetch_queued(phone_call)" do
    let(:status) { PhoneCall::STATE_REMOTE_FETCH_QUEUED }
    let(:asserted_job_class) { FetchRemoteCallJob }

    def observe_event!
      subject.phone_call_remote_fetch_queued(phone_call)
    end

    it { assert_observed! }
  end
end

