require 'rails_helper'

RSpec.describe Event::BatchOperation do
  let(:eventable_factory) { :batch_operation }

  it_behaves_like("resource_event") do
    let(:event) { "queue" }
    let(:asserted_current_status) { BatchOperation::Base::STATE_PREVIEW }
    let(:asserted_new_status) { BatchOperation::Base::STATE_QUEUED }
  end

  describe "validations" do
    let(:eventable) { create(eventable_factory, :status => status) }
    let(:event) { eventable.aasm.events.map { |event| event.name.to_s }.first }
    subject { described_class.new(:eventable => eventable, :event => event) }

    def assert_invalid!
      is_expected.not_to be_valid
      expect(subject.errors[:event]).not_to be_empty
    end

    context "is queued" do
      let(:status) { BatchOperation::Base::STATE_QUEUED }
      it { assert_invalid! }
    end

    context "is running" do
      let(:status) { BatchOperation::Base::STATE_RUNNING }
      it { assert_invalid! }
    end

    context "is finished" do
      let(:status) { BatchOperation::Base::STATE_FINISHED }

      context "can transition" do
        it { is_expected.to be_valid }
      end

      context "can't transition" do
        let(:event) { "queue" }
        it { assert_invalid! }
      end
    end
  end
end
