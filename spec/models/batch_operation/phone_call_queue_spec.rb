require 'rails_helper'

RSpec.describe BatchOperation::PhoneCallQueue do
  let(:factory) { :phone_call_queue_batch_operation }
  include_examples("batch_operation")
  include_examples("phone_call_operation_batch_operation")
  include_examples("hash_attr_accessor", :phone_call_filter_params)
  include_examples("integer_attr_reader", :maximum, :maximum_per_period)

  describe "#strategy" do
    let(:default_strategy) { described_class::DEFAULT_STRATEGY }

    def setup_scenario
      subject.strategy = strategy
    end

    def assert_strategy!
      expect(subject.strategy).to eq(asserted_strategy)
    end

    context "not specified" do
      let(:strategy) { nil }
      let(:asserted_strategy) { default_strategy }
      it { assert_strategy! }
    end

    context "incorrectly specified" do
      let(:strategy) { "foo" }
      let(:asserted_strategy) { default_strategy }
      it { assert_strategy! }
    end

    context "specified" do
      let(:strategy) { "pessimistic" }
      let(:asserted_strategy) { strategy }
      it { assert_strategy! }
    end
  end

  describe "#max_calls_to_enqueue" do
    let(:maximum) { "100" }
    subject { create(factory, :maximum => maximum) }

    context "by default (optimisic)" do
      it { expect(subject.max_calls_to_enqueue).to eq(maximum.to_i) }
    end

    context "strategy = pessimistic" do
    end
  end

  describe "#run!" do
    let(:phone_call) { create(:phone_call) }
    subject { create(factory) }

    def setup_scenario
      super
      phone_call
      subject.run!
    end

    it { expect(phone_call.reload).to be_queued }
  end
end
