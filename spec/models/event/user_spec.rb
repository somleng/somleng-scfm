require 'rails_helper'

RSpec.describe Event::User do
  let(:eventable_factory) { :user }
  let(:eventable) { create(eventable_factory) }

  subject { described_class.new(:eventable => eventable, :event => event) }

  it_behaves_like("resource_event", :assert_status => false) do
    let(:event) { "invite" }
  end

  describe "#save" do
    def setup_scenario
      super
      subject.save
    end

    context "event='invite'" do
      let(:event) { "invite" }
      let(:enqueued_job) { enqueued_jobs.first }

      it {
        expect(enqueued_job).to be_present
        expect(enqueued_job[:job]).to eq(ActionMailer::DeliveryJob)
        expect(enqueued_job[:queue]).to eq(ApplicationJob::DEFAULT_QUEUE_NAME)
      }
    end
  end
end
