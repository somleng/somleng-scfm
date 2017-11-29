require 'rails_helper'

RSpec.describe "Phone Calls" do
  include SomlengScfm::SpecHelpers::RequestHelpers
  let(:callout_participation) { create(:callout_participation) }
  let(:body) { {} }
  let(:factory_attributes) { {} }
  let(:phone_call) { create(:phone_call, factory_attributes) }
  let(:execute_request_before) { true }

  def execute_request
    do_request(method, url, body)
  end

  def setup_scenario
    super
    execute_request if execute_request_before
  end

  describe "GET '/phone_calls'" do
    let(:method) { :get }
    let(:url_params) { {} }
    let(:url) { api_phone_calls_path(url_params) }

    it_behaves_like "resource_filtering" do
      let(:filter_on_factory) { :phone_call }
    end

    it_behaves_like "authorization"
  end

  describe "POST '/api/callout_participation/:callout_participation_id/phone_calls'" do
    let(:method) { :post }
    let(:url) { api_callout_participation_phone_calls_path(callout_participation) }
    let(:metadata) { nil }
    let(:msisdn) { nil }
    let(:remote_request_params) { nil }
    let(:call_flow_logic) { nil }
    let(:body) {
      {
        :metadata => metadata,
        :remote_request_params => remote_request_params,
        :call_flow_logic => call_flow_logic,
        :msisdn => msisdn
      }
    }

    context "valid request" do
      let(:msisdn) { generate(:somali_msisdn) }
      let(:metadata) { { "foo" => "bar"} }
      let(:remote_request_params) { generate(:twilio_request_params) }
      let(:call_flow_logic) { CallFlowLogic::Application.to_s }

      let(:created_phone_call) { callout_participation.phone_calls.last }
      let(:parsed_response_body) { JSON.parse(response.body) }

      def assert_created!
        expect(response.code).to eq("201")
        expect(response.headers["Location"]).to eq(api_phone_call_path(created_phone_call))
        expect(parsed_response_body).to eq(JSON.parse(created_phone_call.to_json))
        expect(parsed_response_body["metadata"]).to eq(metadata)
        expect(parsed_response_body["remote_request_params"]).to eq(remote_request_params)
        expect(parsed_response_body["call_flow_logic"]).to eq(call_flow_logic)
        expect(parsed_response_body["msisdn"]).to eq("+#{msisdn}")
      end

      it { assert_created! }
    end

    context "invalid request" do
      let(:remote_request_params) { { "foo" => "bar" } }

      def assert_invalid!
        expect(response.code).to eq("422")
      end

      it { assert_invalid! }
    end
  end

  describe "'/api/phone_calls/:id'" do
    let(:url) { api_phone_call_path(phone_call) }

    describe "GET" do
      let(:method) { :get }

      def assert_show!
        expect(response.code).to eq("200")
        expect(JSON.parse(response.body)).to eq(JSON.parse(phone_call.to_json))
      end

      it { assert_show! }
    end

    describe "PATCH" do
      let(:method) { :patch }
      let(:factory_attributes) { { "metadata" => {"bar" => "baz" }} }
      let(:metadata) { { "foo" => "bar" } }
      let(:msisdn) { generate(:somali_msisdn) }
      let(:body) {
        {
          :metadata => metadata,
          :metadata_merge_mode => "replace",
          :msisdn => msisdn
        }
      }

      def assert_update!
        expect(response.code).to eq("204")
        expect(phone_call.reload.metadata).to eq(metadata)
        expect(phone_call.msisdn).to eq("+#{msisdn}")
      end

      it { assert_update! }
    end

    describe "DELETE" do
      let(:method) { :delete }

      context "valid request" do
        def assert_destroy!
          expect(response.code).to eq("204")
          expect(PhoneCall.find_by_id(phone_call.id)).to eq(nil)
        end

        it { assert_destroy! }
      end

      context "invalid request" do
        let(:factory_attributes) { { :status => PhoneCall::STATE_QUEUED } }

        def assert_invalid!
          expect(response.code).to eq("422")
        end

        it { assert_invalid! }
      end
    end
  end

  describe "nested indexes" do
    let(:method) { :get }

    def setup_scenario
      create(:phone_call)
      phone_call
      super
    end

    def assert_filtered!
      expect(JSON.parse(response.body)).to eq(JSON.parse([phone_call].to_json))
    end

    describe "GET '/api/callout_participation/:callout_participation_id/phone_calls'" do
      let(:url) { api_callout_participation_phone_calls_path(callout_participation) }
      let(:factory_attributes) { { :callout_participation => callout_participation } }
      it { assert_filtered! }
    end

    describe "GET '/api/callout/:callout_id/phone_calls'" do
      let(:callout) { callout_participation.callout }
      let(:url) { api_callout_phone_calls_path(callout) }
      let(:factory_attributes) { { :callout_participation => callout_participation } }
      it { assert_filtered! }
    end

    describe "GET '/api/contact/:contact_id/phone_calls'" do
      let(:contact) { create(:contact) }
      let(:url) { api_contact_phone_calls_path(contact) }
      let(:factory_attributes) { { :contact => contact } }
      it { assert_filtered! }
    end

    describe "GET '/api/batch_operations/:batch_operation_id/preview/phone_calls'" do
      let(:batch_operation_attributes) { {} }
      let(:batch_operation) { create(batch_operation_factory, batch_operation_attributes) }
      let(:url) { api_batch_operation_preview_phone_calls_path(batch_operation) }

      context "valid requests" do
        let(:factory_attributes) { { :metadata => { "foo" => "bar", "bar" => "foo" } } }

        let(:batch_operation_attributes) {
          {
            :phone_call_filter_params => factory_attributes.slice(:metadata)
          }
        }

        context "BatchOperation::PhoneCallQueue" do
          let(:batch_operation_factory) { :phone_call_queue_batch_operation }
          it { assert_filtered! }
        end

        context "BatchOperation::PhoneCallQueueRemoteFetch" do
          let(:batch_operation_factory) { :phone_call_queue_remote_fetch_batch_operation }
          it { assert_filtered! }
        end
      end

      context "invalid request" do
        let(:execute_request_before) { false }
        let(:batch_operation) { create(:phone_call_create_batch_operation) }
        it {expect { execute_request }.to raise_error(ActiveRecord::RecordNotFound) }
      end
    end

    describe "GET '/api/batch_operations/:batch_operation_id/phone_calls'" do
      let(:batch_operation) { create(batch_operation_factory) }
      let(:url) { api_batch_operation_phone_calls_path(batch_operation) }

      context "valid requests" do
        context "BatchOperation::PhoneCallCreate" do
          let(:batch_operation_factory) { :phone_call_create_batch_operation }
          let(:factory_attributes) { { :create_batch_operation => batch_operation } }
          it { assert_filtered! }
        end

        context "BatchOperation::PhoneCallQueue" do
          let(:batch_operation_factory) { :phone_call_queue_batch_operation }
          let(:factory_attributes) { { :queue_batch_operation => batch_operation } }
          it { assert_filtered! }
        end

        context "BatchOperation::PhoneCallQueueRemoteFetch" do
          let(:batch_operation_factory) { :phone_call_queue_remote_fetch_batch_operation }
          let(:factory_attributes) { { :queue_remote_fetch_batch_operation => batch_operation } }
          it { assert_filtered! }
        end
      end

      context "invalid request" do
        let(:execute_request_before) { false }
        let(:batch_operation_factory) { :callout_population }
        it { expect { execute_request }.to raise_error(ActiveRecord::RecordNotFound) }
      end
    end
  end
end
