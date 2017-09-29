require 'rails_helper'

RSpec.describe EnqueueCallsTask do
  let(:callout_status) { :running }
  let(:callout) { create(:callout, :status => callout_status) }
  let(:max_calls_to_enqueue) { nil }
  let(:num_phone_numbers_to_call) { 2 }

  let(:phone_numbers_to_call) {
    create_list(:phone_number, num_phone_numbers_to_call, :callout => callout)
  }

  before do
    setup_scenario
  end

  def setup_scenario
    stub_env(env)
  end

  def env
    {
      "ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE" => (
        max_calls_to_enqueue && max_calls_to_enqueue.to_s
      )
    }
  end

  describe "#run!" do
    include SomlengScfm::SpecHelpers::SomlengClientHelpers

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
    let(:asserted_called_phone_number) { phone_numbers_to_call[0] }
    let(:asserted_phone_calls_count) { num_phone_numbers_to_call }
    let(:asserted_remote_error_message) { nil }

    def setup_scenario
      super
      stub_request(:post, asserted_remote_api_endpoint).to_return(asserted_remote_response)
      phone_numbers_to_call
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

      expect(queued_call.remote_error_message).to eq(asserted_remote_error_message)
    end

    context "remote call was enqueued successfully" do
      let(:asserted_remote_response_status) { 200 }
      let(:asserted_status) { "queued" }
      it { assert_run! }
    end

    context "call was not enqueued successfully" do
      let(:asserted_remote_response_status) { 422 }
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

  describe "#optimistic_num_calls_to_enqueue" do
    let(:result) { subject.optimistic_num_calls_to_enqueue }
    let(:asserted_result) { max_calls_to_enqueue }

    def assert_result!
      expect(result).to eq(asserted_result)
    end

    context "by default" do
      it { assert_result! }
    end

    context "ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE=1" do
      let(:max_calls_to_enqueue) { 1 }
      it { assert_result! }
    end
  end

  describe "#pessimistic_num_calls_to_enqueue" do
    let(:result) { subject.pessimistic_num_calls_to_enqueue }

    def assert_result!
      expect(result).to eq(asserted_result)
    end

    let(:pessimistic_min_calls_to_enqueue) { 1 }
    let(:num_phone_numbers_to_call) { 3 }

    def setup_scenario
      phone_numbers_to_call
      create(:phone_number) # callout not running
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
        let(:asserted_result) { num_phone_numbers_to_call }
        it { assert_result! }
      end

      context "calls are queued" do
        let(:num_queued_calls) { num_phone_numbers_to_call }
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
        let(:num_queued_calls) { num_phone_numbers_to_call }
        let(:asserted_result) { pessimistic_min_calls_to_enqueue }
        it { assert_result! }
      end
    end
  end
end
