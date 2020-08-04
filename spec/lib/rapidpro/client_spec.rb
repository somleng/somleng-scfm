require "rails_helper"

module Rapidpro
  RSpec.describe Client do
    describe "#start_flow" do
      it "starts a flow" do
        client = Client.new(api_token: "api-token")
        stub_request(:post, %r{https://app.rapidpro.io})

        client.start_flow(flow: "flow-id", urns: "+25223456789")

        expect(WebMock).to have_requested(
          :post,
          "https://app.rapidpro.io/api/v2/flow_starts.json"
        ).with(
          headers: {
            "Authorization" => "Token api-token",
            "Content-Type" => "application/json"
          },
          body: {
            "flow" => "flow-id",
            "urns" => "+25223456789"
          }.to_json
        )
      end
    end
  end
end
