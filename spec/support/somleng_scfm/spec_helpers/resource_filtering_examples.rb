RSpec.shared_examples_for("resource_filtering") do |options = {}|
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
    let(:asserted_count) { asserted_resources.count }
    let(:asserted_parsed_json) { JSON.parse(asserted_resources.to_json) }

    def assert_index!
      super
      expect(response.headers["Total"]).to eq(asserted_count.to_s)
      expect(JSON.parse(response.body)).to eq(asserted_parsed_json)
    end

    if options[:filter_by_account] != false
      context "by account" do
        let(:filtered_resource) {
          create(
            filter_on_factory,
            filter_factory_attributes
          )
        }

        let(:resource_from_different_account) {
          create(
            filter_on_factory
          )
        }

        let(:asserted_resources) { [filtered_resource] }

        def setup_scenario
          resource_from_different_account
          filtered_resource
          super
        end

        it { assert_index! }
      end
    end

    context "by metadata" do
      let(:metadata) {
        {
          "foo" => "bar",
          "bar" => {
            "baz" => "foo"
          }
        }
      }

      let(:resource_with_matching_metadata) {
        create(
          filter_on_factory,
          filter_factory_attributes.merge(:metadata => metadata)
        )
      }

      let(:resource_without_matching_metadata) {
        create(filter_on_factory, filter_factory_attributes)
      }

      let(:query_params) { { "metadata" => metadata } }
      let(:url_params) { { :q => query_params } }

      let(:asserted_resources) { [resource_with_matching_metadata] }

      def setup_scenario
        resource_with_matching_metadata
        resource_without_matching_metadata
        super
      end

      it { assert_index! }
    end
  end
end
