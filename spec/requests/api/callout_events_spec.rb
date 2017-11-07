require 'rails_helper'

RSpec.describe "POST '/callouts/:callout_id/callout_events'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:callout) { create(:callout) }
  let(:url) { api_callout_callout_events_path(callout) }
  let(:params) { {} }

  def setup_scenario
    super
    do_request(:post, url, params)
  end

  context "invalid request" do
    def assert_invalid!
      expect(response.code).to eq("422")
    end

    it { assert_invalid! }
  end

  context "valid request" do
    let(:params) { {:event => "start"} }

    def assert_create!
      expect(response.code).to eq("201")
      expect(response.headers["Location"]).to eq(api_callout_path(callout))
      expect(response.body).to eq(callout.reload.to_json)
      expect(JSON.parse(response.body)["status"]).to eq("running")
    end

    it { assert_create! }
  end
end

