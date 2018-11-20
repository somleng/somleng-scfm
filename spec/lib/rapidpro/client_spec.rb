require "rails_helper"

module Rapidpro
  RSpec.describe Client do
    describe "#start_flow" do
      it "starts a flow" do
        client = described_class.new(api_token: "api-token")
        stub_request(:post, "https://app.rapidpro.io/api/v2/flow_starts.json")

        client.start_flow(flow: "flow-id", urns: "+25223456789")

        request = WebMock.requests.last
        expect(request.uri.scheme).to eq("https")
        expect(request.uri.host).to eq("app.rapidpro.io")
        expect(request.uri.path).to eq("/api/v2/flow_starts.json")
        expect(request.headers.fetch("Authorization")).to include("api-token")
        expect(request.headers.fetch("Content-Type")).to eq("application/json")
        expect(JSON.parse(request.body)).to include(
          "flow" => "flow-id",
          "urns" => "+25223456789"
        )
      end
    end
  end
end
