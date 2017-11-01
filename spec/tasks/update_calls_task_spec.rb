require 'rails_helper'

RSpec.describe UpdateCallsTask do
  describe UpdateCallsTask::Install do
    describe ".rake_tasks" do
      it { expect(described_class.rake_tasks).to eq([:run!]) }
    end
  end

  describe "#run!" do
    include SomlengScfm::SpecHelpers::SomlengClientHelpers

    let(:remote_call_id) { "call-sid" }
    let(:queued_phone_call) {
      create(
        :phone_call,
        :not_recently_created,
        :status => "queued",
        :remote_call_id => remote_call_id
      )
    }

    def asserted_remote_api_endpoint
      super("Calls/#{remote_call_id}")
    end

    let(:asserted_remote_response_body) { { "status" => "completed" }.to_json }
    let(:asserted_status) { "completed" }

    def setup_scenario
      super
      stub_request(:get, asserted_remote_api_endpoint).to_return(asserted_remote_response)
      queued_phone_call
      create(:phone_call)
      subject.run!
    end

    def assert_run!
      assert_somleng_client_request!
      queued_phone_call.reload
      expect(queued_phone_call.remote_response["status"]).to eq(asserted_status)
      expect(queued_phone_call.status).to eq(asserted_status)
    end

    it { assert_run! }
  end
end
