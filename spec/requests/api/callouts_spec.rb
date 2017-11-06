require 'rails_helper'

RSpec.describe "'/api/callouts'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  describe "GET '/'" do
    let(:url) { api_callouts_path(url_params) }
    let(:asserted_resources) { [] }
    let(:asserted_count) { asserted_resources.count }
    let(:asserted_body) { JSON.parse(asserted_resources.to_json) }
    let(:url_params) { {} }

    def setup_scenario
      super
      do_request(:get, url)
    end

    def assert_index!
      super
      expect(response.headers["Total"]).to eq(asserted_count.to_s)
      expect(JSON.parse(response.body)).to eq(asserted_body)
    end

    it_behaves_like "authorization"
    it_behaves_like "index_filtering" do
      let(:filter_on_factory) { :callout }
    end
  end

  describe "GET '/:id'" do
    let(:callout) { create(:callout) }
    let(:url) { api_callout_path(callout) }

    def setup_scenario
      super
      do_request(:get, url)
    end

    def assert_show!
      expect(response.code).to eq("200")
      expect(response.body).to eq(callout.to_json)
    end

    it { assert_show! }
  end
end
