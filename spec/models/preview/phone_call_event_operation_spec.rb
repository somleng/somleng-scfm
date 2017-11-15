require 'rails_helper'

RSpec.describe Preview::PhoneCallEventOperation do
  let(:callout_participation_filter_params) { {} }
  let(:callout_filter_params) { {} }

  let(:batch_operation) {
    create(
      batch_operation_factory,
      :callout_participation_filter_params => callout_participation_filter_params,
      :callout_filter_params => callout_filter_params
    )
  }

  subject { described_class.new(:previewable => batch_operation) }

  describe "filtering" do
    let(:callout_factory_params) { { :status => Callout::STATE_RUNNING } }
    let(:callout) { create(:callout, callout_factory_params) }

    let(:callout_participation_factory_params) {
      {
        :metadata => {"foo" => "bar", "bar" => "foo"}
      }
    }

    let(:callout_participation) {
      create(
        :callout_participation,
        {:callout => callout}.merge(callout_participation_factory_params)
      )
    }

    let(:phone_call_factory_params) { { :status => PhoneCall::STATE_CREATED } }

    let(:phone_call) {
      create(
        :phone_call,
        {:callout_participation => callout_participation}.merge(phone_call_factory_params)
      )
    }

    let(:phone_call_filter_params) {
      phone_call_factory_params.slice(:status)
    }

    let(:callout_filter_params) {
      callout_factory_params.slice(:status)
    }

    let(:callout_participation_filter_params) {
      callout_participation_factory_params.slice(:metadata)
    }

    def setup_scenario
      super
      phone_call
      create(:phone_call, phone_call_filter_params)
    end

    describe "#phone_calls" do
      def assert_phone_calls!
        expect(subject.phone_calls).to match_array([phone_call])
      end

      context "previewable type is BatchOperation::PhoneCallQueue" do
        let(:batch_operation_factory) { :phone_call_queue_batch_operation }
        it { assert_phone_calls! }
      end

      context "previewable type is BatchOperation::PhoneCallQueueRemoteFetch" do
        let(:batch_operation_factory) { :phone_call_queue_remote_fetch_batch_operation }
        it { assert_phone_calls! }
      end
    end
  end
end
