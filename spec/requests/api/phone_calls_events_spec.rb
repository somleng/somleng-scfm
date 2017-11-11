require 'rails_helper'

RSpec.describe "POST '/api/phone_calls/:phone_call_id/phone_call_events'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:method) { :post }
  let(:factory_attributes) { {} }
  let(:phone_call) { create(:phone_call, factory_attributes) }
  let(:url) { api_phone_call_phone_call_events_path(phone_call) }
  let(:event) { nil }
  let(:body) { { :event => event } }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  context "valid request" do
    let(:event) { :queue }
    let(:body) { { :event => event } }

    def assert_created!
      expect(response.code).to eq("201")
      expect(response.headers["Location"]).to eq(api_phone_call_path(phone_call))
      expect(JSON.parse(response.body)).to eq(JSON.parse(phone_call.reload.to_json))
      expect(phone_call).to be_queued
    end

    it { assert_created! }
  end

  context "invalid request" do
    let(:event) { :queue_remote }
    let(:factory_attributes) { {:status => PhoneCall::STATE_QUEUED} }

    def assert_invalid!
      expect(response.code).to eq("422")
    end

    it { assert_invalid! }
  end
end
