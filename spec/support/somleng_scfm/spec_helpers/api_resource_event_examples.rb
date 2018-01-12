RSpec.shared_examples_for "api_resource_event" do |options = {}|
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
    let(:parsed_response_body) { JSON.parse(response.body) }
    let(:options) { options }

    def assert_create!
      expect(response.code).to eq("201")
      expect(response.headers["Location"]).to eq(eventable_path)
      expect(parsed_response_body).to eq(JSON.parse(eventable.reload.to_json))
      expect(parsed_response_body["status"]).to eq(asserted_new_status) if options[:assert_status] != false
    end

    it { assert_create! }
  end
end
