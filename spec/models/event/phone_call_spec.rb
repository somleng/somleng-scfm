require "rails_helper"

RSpec.describe Event::PhoneCall do
  let(:eventable_factory) { :phone_call }

  it_behaves_like("resource_event") do
    let(:event) { "queue" }
    let(:asserted_current_status) { PhoneCall::STATE_CREATED }
    let(:asserted_new_status) { PhoneCall::STATE_QUEUED }
  end

  describe "validations" do
    subject { build_event(eventable, event: event) }

    let(:eventable) { create(eventable_factory, status: status) }
    let(:event) { eventable.aasm.events.map { |event| event.name.to_s }.first }

    def assert_invalid!
      expect(subject).not_to be_valid
      expect(subject.errors[:event]).not_to be_empty
    end

    context "when phone call is created" do
      subject { build_event(phone_call) }

      let(:phone_call) { create(:phone_call, :created) }

      it { is_expected.to allow_value("queue").for(:event) }
      it { is_expected.not_to allow_value("queue_remote_fetch").for(:event) }
    end

    context "when phone call is queued" do
      subject { build_event(phone_call) }

      let(:phone_call) { create(:phone_call, :queued) }

      it { is_expected.not_to allow_value("queue").for(:event) }
      it { is_expected.not_to allow_value("queue_remote_fetch").for(:event) }
    end

    context "when phone call is remotely queued" do
      subject { build_event(phone_call) }

      let(:phone_call) { create(:phone_call, :remotely_queued) }

      it { is_expected.not_to allow_value("queue").for(:event) }
      it { is_expected.to allow_value("queue_remote_fetch").for(:event) }
    end
  end

  describe "#save" do
    it "queues a job fetching the remote status" do
      phone_call = create(:phone_call, :remotely_queued)
      event = build_event(phone_call, event: "queue_remote_fetch")

      expect { event.save }.to have_enqueued_job(FetchRemoteCallJob)
    end
  end

  def build_event(eventable, event: nil)
    described_class.new(eventable: eventable, event: event)
  end
end
