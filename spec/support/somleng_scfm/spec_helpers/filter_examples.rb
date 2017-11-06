RSpec.shared_examples_for "filter" do
  describe "#resources" do
    context "filtering by metadata" do
      def filter_params
        super.merge(
          "metadata" => {
            "foo" => "bar",
            "bar" => "foo"
          }
        )
      end

      let(:factory_metadata) {
        {
          "foo" => metadata_value_1,
          "bar" => "foo"
        }
      }

      let(:metadata_value_1) { "bar" }
      let(:resource) { create(factory, :metadata => factory_metadata) }

      def setup_scenario
        super
        resource
      end

      def assert_filter!
        expect(subject.resources).to match_array(asserted_results)
      end

      context "with correct filter" do
        let(:asserted_results) { [resource] }
        it { assert_filter! }
      end

      context "with incorrect filter" do
        let(:metadata_value_1) { "baz" }
        let(:asserted_results) { [] }
        it { assert_filter! }
      end
    end
  end
end
