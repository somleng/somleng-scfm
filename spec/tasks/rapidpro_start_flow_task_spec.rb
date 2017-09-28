require 'rails_helper'

RSpec.describe RapidproStartFlowTask do
  describe "#run!" do
    before do
      setup_scenario
    end

    def setup_scenario
      stub_env(env)
      stub_request(:post, asserted_rapidpro_endpoint).to_return(mocked_remote_response)
      phone_call_to_run_flow
      phone_call_not_completed
      phone_call_flow_already_run
      subject.run!
    end

    let(:mocked_remote_response) {
      {
        :body => mocked_remote_response_body,
        :status => mocked_remote_response_status,
        :headers => mocked_remote_response_headers,
      }
    }

    let(:mocked_remote_response_body) {
      {
        "id" => mocked_remote_response_body_id,
        "uuid" => mocked_remote_response_body_uuid
      }.to_json
    }

    let(:mocked_remote_response_body_id) { 1234 }
    let(:mocked_remote_response_body_uuid) { SecureRandom.uuid }
    let(:mocked_remote_response_status) { 201 }
    let(:mocked_remote_response_headers_content_type) { "application/json" }

    let(:mocked_remote_response_headers) {
      {
        "Content-Type" => mocked_remote_response_headers_content_type
      }
    }

    let(:rapidpro_flow_id_key) { "rapidpro_flow_id" }
    let(:existing_rapidpro_flow_id) { 99 }

    let(:phone_call_to_run_flow) {
      create(:phone_call, :status => "completed")
    }

    let(:phone_call_not_completed) {
      create(:phone_call)
    }

    let(:phone_call_flow_already_run) {
      create(
        :phone_call,
        :status => "completed",
        :metadata => {
          rapidpro_flow_id_key => existing_rapidpro_flow_id
        }
      )
    }

    let(:asserted_rapidpro_endpoint) {
      "#{rapidpro_base_url}/#{rapidpro_api_version}/flow_starts.json"
    }

    let(:rapidpro_base_url) { "https://app.rapidpro.io/api" }
    let(:rapidpro_api_version) { "v2" }
    let(:rapidpro_api_token) { "api-token" }

    let(:rapidpro_start_flow_request_params_flow_id) {
      "flow-id"
    }

    let(:rapidpro_start_flow_request_urn_telegram_id) {
      "telegram-id"
    }

    let(:rapidpro_start_flow_request_urns) {
      ["telegram:#{rapidpro_start_flow_request_urn_telegram_id}"]
    }

    let(:rapidpro_start_flow_request_params) {
      {
        "flow" => rapidpro_start_flow_request_params_flow_id,
        "groups" => [],
        "contacts" => [],
        "urns" => rapidpro_start_flow_request_urns,
        "extra" => {}
      }
    }

    def env
      {
        "RAPIDPRO_BASE_URL" => rapidpro_base_url,
        "RAPIDPRO_API_VERSION" => rapidpro_api_version,
        "RAPIDPRO_API_TOKEN" => rapidpro_api_token,
        "RAPIDPRO_START_FLOW_TASK_REMOTE_REQUEST_PARAMS" => rapidpro_start_flow_request_params.to_json
      }
    end

    def assert_run!
      expect(WebMock.requests.count).to eq(1)
      phone_call_flow_already_run.reload
      phone_call_not_completed.reload
      phone_call_to_run_flow.reload

      expect(
        phone_call_flow_already_run.metadata[rapidpro_flow_id_key]
      ).to eq(existing_rapidpro_flow_id)

      expect(
        phone_call_not_completed.metadata[rapidpro_flow_id_key]
      ).to eq(nil)

      expect(
        phone_call_to_run_flow.metadata[rapidpro_flow_id_key]
      ).to eq(mocked_remote_response_body_id)

      expect(
        phone_call_to_run_flow.metadata["rapidpro_flow_started_at"]
      ).to be_present

      request = WebMock.requests.last
      request_body = JSON.parse(request.body)
      request_headers = request.headers

      expect(request_headers["Content-Type"]).to eq("application/json")
      expect(request_headers["Authorization"]).to eq("Token #{rapidpro_api_token}")
      expect(request_body).to eq(rapidpro_start_flow_request_params)
    end

    it { assert_run! }
  end
end
