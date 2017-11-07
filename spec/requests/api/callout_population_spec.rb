require 'rails_helper'

RSpec.describe "'/callout_populations'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  def setup_scenario
    super
    do_request(method, url, body)
  end

  describe "POST '/callouts/:callout_id/callout_populations'" do
    let(:method) { :post }
    let(:body) { { :metadata => metadata } }
    let(:metadata) { { "foo" => "bar" } }
    let(:callout) { create(:callout) }

    let(:url) { api_callout_callout_populations_path(callout) }

    context "successful request" do
      let(:asserted_created_callout_population) { callout.callout_populations.last }
      let(:parsed_response) { JSON.parse(response.body) }

      def assert_created!
        expect(response.code).to eq("201")
        expect(parsed_response).to eq(JSON.parse(asserted_created_callout_population.to_json))
        expect(parsed_response["metadata"]).to eq(metadata)
      end

      it { assert_created! }
    end

    context "already populated" do
    end
  end
end
