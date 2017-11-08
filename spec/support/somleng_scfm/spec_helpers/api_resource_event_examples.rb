RSpec.shared_examples_for "api_resource_event" do
  def setup_scenario
    super
    do_request(:post, url, body)
  end

  context "invalid request" do
    let(:body) { {} }

    def assert_invalid!
      expect(response.code).to eq("422")
    end

    it { assert_invalid! }
  end

  context "valid request" do
    let(:body) { {:event => event} }

    def assert_create!
      expect(response.code).to eq("201")
      expect(response.headers["Location"]).to eq(eventable_path)
      expect(response.body).to eq(eventable.reload.to_json)
      expect(JSON.parse(response.body)["status"]).to eq(asserted_new_status)
    end

    it { assert_create! }
  end
end
