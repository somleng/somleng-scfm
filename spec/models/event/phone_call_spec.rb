require 'rails_helper'

RSpec.describe Event::PhoneCall do
  let(:eventable_factory) { :phone_call }

  it_behaves_like("resource_event") do
    let(:event) { "queue" }
    let(:asserted_current_status) { PhoneCall::STATE_CREATED }
    let(:asserted_new_status) { PhoneCall::STATE_QUEUED }
  end

  describe "validations" do
    let(:eventable) { create(eventable_factory, :status => status) }
    let(:event) { eventable.aasm.events.map { |event| event.name.to_s }.first }
    subject { described_class.new(:eventable => eventable, :event => event) }

    def assert_invalid!
      is_expected.not_to be_valid
      expect(subject.errors[:event]).not_to be_empty
    end

    context "created" do
      let(:status) { PhoneCall::STATE_CREATED }
      it { is_expected.to be_valid }
    end

    context "queued" do
      let(:status) { PhoneCall::STATE_QUEUED }
      it { assert_invalid! }
    end

    context "remotely_queued" do
      let(:status) { PhoneCall::STATE_REMOTELY_QUEUED }
      it { is_expected.to be_valid }
    end

    context "can't transition" do
      let(:status) { PhoneCall::STATE_REMOTELY_QUEUED }
      let(:event) { "queue" }
      it { assert_invalid! }
    end
  end
end
