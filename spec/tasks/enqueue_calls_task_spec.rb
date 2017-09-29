require 'rails_helper'

RSpec.describe EnqueueCallsTask do
  describe "#run!" do
    include SomlengScfm::SpecHelpers::SomlengClientHelpers

    let(:callout) { create(:callout) }
    let(:msisdn) { "+85512345678" }

    let(:asserted_queued_phone_number) {
      create(
        :phone_number,
        :callout => callout,
        :msisdn => msisdn
      )
    }

    let(:asserted_not_queued_phone_number) {
      create(:phone_number, :callout => callout)
    }

    let(:default_call_params_from) { "1234" }
    let(:default_call_params_url) { "http://demo.twilio.com/docs/voice.xml" }
    let(:default_call_params_method) { "GET" }

    let(:default_call_params) {
      {
        "from" => default_call_params_from,
        "url" => default_call_params_url,
        "method" => default_call_params_method
      }.to_json
    }

    def env
      super.merge(
        "ENQUEUE_CALLS_TASK_DEFAULT_CALL_PARAMS" => default_call_params
      )
    end

    def asserted_remote_api_endpoint
      super("Calls")
    end

    let(:asserted_remote_response_body) { { "sid" => "1234" }.to_json }

    before do
      setup_scenario
    end

    def setup_scenario
      stub_env(env)
      stub_request(:post, asserted_remote_api_endpoint).to_return(asserted_remote_response)
      asserted_queued_phone_number
      asserted_not_queued_phone_number
      subject.run!
    end

    def assert_run!
      assert_somleng_client_request!
      expect(callout.phone_calls).to be_present
      expect(callout.phone_calls.size).to eq(described_class::DEFAULT_MAX_CALLS_TO_ENQUEUE)
      expect(asserted_queued_phone_number.phone_calls).to be_present
      expect(asserted_not_queued_phone_number.phone_calls).not_to be_present
      queued_call = callout.phone_calls.first!
      request = client_requests.last
      request_body = client_request_body(request)
      expect(request_body).to include(
        "From" => default_call_params_from,
        "To" => msisdn,
        "Url" => default_call_params_url,
        "Method" => default_call_params_method
      )
      expect(queued_call.remote_error_message).to eq(asserted_remote_error_message)
      expect(queued_call.status).to eq(asserted_status)
    end

    context "remote call was enqueued successfully" do
      let(:asserted_remote_response_status) { 200 }
      let(:asserted_status) { "queued" }
      let(:asserted_remote_error_message) { nil }
      it { assert_run! }
    end

    context "call was not enqueued successfully" do
      let(:asserted_remote_response_status) { 422 }
      let(:asserted_remote_error_message) { "Unable to create record" }
      let(:asserted_status) { "errored" }
      it { assert_run! }
    end
  end

  describe "#num_calls_to_enqueue" do
    let(:result) { subject.send(:num_calls_to_enqueue) }
    let(:max_calls_to_enqueue) { 3 }

    before do
      setup_scenario
    end

    def setup_scenario
      stub_env(env)
    end

    def env
      {
        "ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE" => max_calls_to_enqueue.to_s,
        "ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY" => strategy
      }
    end

    def assert_num_calls_to_enqueue!
      expect(result).to eq(asserted_num_calls_to_enqueue)
    end

    context "by default" do
      let(:strategy) { nil }
      let(:asserted_num_calls_to_enqueue) { max_calls_to_enqueue }

      it { assert_num_calls_to_enqueue! }
    end

    context "ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY=pessimistic" do
      let(:callout) { create(:callout) }
      let(:strategy) { "pessimistic" }
      let(:pessimistic_min_calls_to_enqueue) { 2 }
      let(:status) { "queued" }

      def setup_scenario
        create_list(:phone_call, currently_queued_calls, :status => status, :callout => callout)
        super
      end

      def env
        super.merge(
          "ENQUEUE_CALLS_TASK_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE" => pessimistic_min_calls_to_enqueue.to_s
        )
      end

      context "max calls are currently queued" do
        let(:currently_queued_calls) { max_calls_to_enqueue }
        let(:asserted_num_calls_to_enqueue) { pessimistic_min_calls_to_enqueue }

        it { assert_num_calls_to_enqueue! }
      end

      context "no calls are currently queued" do
        let(:currently_queued_calls) { 0 }
        let(:asserted_num_calls_to_enqueue) { max_calls_to_enqueue }

        it { assert_num_calls_to_enqueue! }
      end
    end
  end
end
