require 'rails_helper'

RSpec.describe EnqueueCallsTask do
  describe EnqueueCallsTask::Install do
    describe ".rake_tasks" do
      it { expect(described_class.rake_tasks).to eq([:run!]) }
    end
  end

  describe "InstanceMethods" do
    let(:callout_status) { :running }
    let(:callout) { create(:callout, :status => callout_status) }
    let(:max_calls_to_enqueue) { nil }
    let(:max_calls_per_period) { nil }
    let(:max_calls_per_period_hours) { nil }
    let(:num_callout_participations_to_call) { 2 }

    let(:callout_participations_to_call) {
      create_list(:callout_participation, num_callout_participations_to_call, :callout => callout)
    }

    def env
      {
        "ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE" => (
          max_calls_to_enqueue && max_calls_to_enqueue.to_s
        ),
        "ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD" => (
          max_calls_per_period && max_calls_per_period.to_s
        ),
        "ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD_HOURS" => (
          max_calls_per_period_hours && max_calls_per_period_hours.to_s
        )
      }
    end

    describe "#run!" do
      include SomlengScfm::SpecHelpers::SomlengClientHelpers

      let(:default_call_params_from) { "1234" }
      let(:default_call_params_url) { "http://demo.twilio.com/docs/voice.xml" }
      let(:default_call_params_method) { "GET" }
      let(:default_call_params_to) { "dummy" }

      let(:default_call_params) {
        {
          "to" => default_call_params_to,
          "from" => default_call_params_from,
          "url" => default_call_params_url,
          "method" => default_call_params_method
        }.to_json
      }

      def env
        super.merge(
          "ENQUEUE_CALLS_TASK_DEFAULT_SOMLENG_REQUEST_PARAMS" => default_call_params
        )
      end

      def asserted_remote_api_endpoint
        super("Calls")
      end

      let(:remote_response_body_sid) { "1234" }
      let(:remote_response_body_direction) { "outbound-api" }

      let(:asserted_remote_response_body) {
        {
          "sid" => remote_response_body_sid,
          "direction" => remote_response_body_direction
        }.to_json
      }

      let(:asserted_phone_calls_count) { num_callout_participations_to_call }
      let(:asserted_remote_error_message) { nil }
      let(:asserted_remote_call_id) { remote_response_body_sid }
      let(:asserted_remote_direction) { remote_response_body_direction }

      def setup_scenario
        super
        stub_request(:post, asserted_remote_api_endpoint).to_return(asserted_remote_response)
        callout_participations_to_call
        subject.run!
      end

      def assert_run!
        expect(callout.phone_calls.size).to eq(asserted_phone_calls_count)
        queued_call = callout.phone_calls.first!

        assert_somleng_client_request!
        request = client_requests.first
        request_body = client_request_body(request)

        expect(request_body).to include(
          "From" => default_call_params_from,
          "To" => queued_call.msisdn,
          "Url" => default_call_params_url,
          "Method" => default_call_params_method
        )

        expect(queued_call.remote_call_id).to eq(asserted_remote_call_id)
        expect(queued_call.remote_direction).to eq(asserted_remote_direction)
        expect(queued_call.remote_error_message).to eq(asserted_remote_error_message)
        expect(queued_call.contact).to eq(queued_call.callout_participation.contact)
      end

      context "remote call was enqueued successfully" do
        let(:asserted_remote_response_status) { 200 }
        let(:asserted_status) { "queued" }
        it { assert_run! }
      end

      context "call was not enqueued successfully" do
        let(:asserted_remote_response_status) { 422 }
        let(:asserted_remote_call_id) { nil }
        let(:asserted_remote_direction) { nil }
        let(:asserted_remote_error_message) { "Unable to create record" }
        let(:asserted_status) { "errored" }
        it { assert_run! }
      end

      context "ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE=1" do
        let(:max_calls_to_enqueue) { 1 }
        let(:asserted_phone_calls_count) { max_calls_to_enqueue }
        it { assert_run! }
      end
    end

    describe "limits" do
      def assert_result!
        expect(result).to eq(asserted_result)
      end

      describe "#optimistic_max_num_calls_to_enqueue" do
        let(:result) { subject.optimistic_max_num_calls_to_enqueue }
        let(:asserted_result) { max_calls_to_enqueue }

        context "by default" do
          it { assert_result! }
        end

        context "ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE=1" do
          let(:max_calls_to_enqueue) { 1 }
          it { assert_result! }
        end
      end

      describe "#max_num_calls_to_enqueue" do
        let(:result) { subject.max_num_calls_to_enqueue }

        context "ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD=100" do
          let(:max_calls_per_period) { 100 }
          let(:asserted_result) { 100 }
          let(:queued_at) { nil }
          let(:hours) { 1 }

          def setup_scenario
            super
            create(:phone_call, :queued_at => queued_at)
          end

          context "by default" do
            context "calls have been queued in the last 24 hours" do
              let(:asserted_result) { 99 }
              let(:queued_at) { 23.hour.ago }
              it { assert_result! }
            end

            context "no calls have been queued in the last 24 hours" do
              let(:asserted_result) { 100 }
              let(:queued_at) { 24.hour.ago }
              it { assert_result! }
            end
          end

          context "ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD_HOURS=1" do
            let(:max_calls_per_period_hours) { 1 }

            context "calls have been queued in the last 1 hour" do
              let(:asserted_result) { 99 }
              let(:queued_at) { Time.now }
              it { assert_result! }
            end

            context "no calls have been queued in the last 1 hour" do
              let(:asserted_result) { 100 }
              let(:queued_at) { 1.hour.ago }
              it { assert_result! }
            end
          end
        end
      end

      describe "#pessimistic_max_num_calls_to_enqueue" do
        let(:result) { subject.pessimistic_max_num_calls_to_enqueue }

        let(:pessimistic_min_calls_to_enqueue) { 1 }
        let(:num_callout_participations_to_call) { 3 }

        def setup_scenario
          callout_participations_to_call
          create(:callout_participation) # callout not running
          create_list(:phone_call, num_queued_calls, :status => :queued, :callout => callout)
          super
        end

        def env
          super.merge(
            "ENQUEUE_CALLS_TASK_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE" => pessimistic_min_calls_to_enqueue.to_s
          )
        end

        context "by default" do
          context "no calls are queued" do
            let(:num_queued_calls) { 0 }
            let(:asserted_result) { num_callout_participations_to_call }
            it { assert_result! }
          end

          context "calls are queued" do
            let(:num_queued_calls) { num_callout_participations_to_call }
            let(:asserted_result) { pessimistic_min_calls_to_enqueue }
            it { assert_result! }
          end
        end

        context "ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE=1" do
          let(:max_calls_to_enqueue) { 2 }

          context "no calls are queued" do
            let(:num_queued_calls) { 0 }
            let(:asserted_result) { max_calls_to_enqueue }
            it { assert_result! }
          end

          context "calls are queued" do
            let(:num_queued_calls) { num_callout_participations_to_call }
            let(:asserted_result) { pessimistic_min_calls_to_enqueue }
            it { assert_result! }
          end
        end
      end
    end
  end
end
