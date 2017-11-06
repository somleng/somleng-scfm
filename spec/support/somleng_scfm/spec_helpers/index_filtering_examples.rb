RSpec.shared_examples_for("index_filtering") do
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
    let(:metadata) { {"foo" => "bar", "bar" => "baz"} }
    let(:resource_with_matching_metadata) { create(filter_on_factory, :metadata => metadata) }
    let(:resource_without_matching_metadata) { create(filter_on_factory) }
    let(:asserted_count) { asserted_resources.count }
    let(:asserted_resources) { [resource_with_matching_metadata] }
    let(:asserted_body) { asserted_resources.to_json }
    let(:url_params) { { "metadata" => metadata } }

    def setup_scenario
      resource_with_matching_metadata
      resource_without_matching_metadata
      super
    end

    it { assert_index! }
  end
end
