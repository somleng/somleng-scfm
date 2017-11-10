RSpec.shared_examples_for("resource_filtering") do
  context "not filtering" do
    let(:resource) { create(filter_on_factory) }
    let(:asserted_resources) { [resource] }

    def setup_scenario
      resource
      super
    end

    it { assert_index! }
  end

  context "filtering" do
    let(:metadata) {
      {
        "foo" => "bar",
        "bar" => {
          "baz" => "foo"
        }
      }
    }

    let(:resource_with_matching_metadata) { create(filter_on_factory, :metadata => metadata) }
    let(:resource_without_matching_metadata) { create(filter_on_factory) }
    let(:asserted_count) { asserted_resources.count }
    let(:asserted_resources) { [resource_with_matching_metadata] }
    let(:asserted_parsed_json) { JSON.parse(asserted_resources.to_json) }
    let(:query_params) { { "metadata" => metadata } }
    let(:url_params) { { :q => query_params } }

    def setup_scenario
      resource_with_matching_metadata
      resource_without_matching_metadata
      super
    end

    def assert_index!
      super
      expect(response.headers["Total"]).to eq(asserted_count.to_s)
      expect(JSON.parse(response.body)).to eq(asserted_parsed_json)
    end

    it { assert_index! }
  end
end
