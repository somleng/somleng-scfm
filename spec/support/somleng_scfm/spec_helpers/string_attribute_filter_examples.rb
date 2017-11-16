RSpec.shared_examples_for "string_attribute_filter" do |string_attributes|
  string_attributes.each do |string_attribute, test_value|
    context "filtering by #{string_attribute}" do
      let(:resource_string) { test_value }
      let(:filter_attribute) { string_attribute.to_sym }
      let(:resource) { create(filterable_factory, string_attribute => resource_string) }

      def setup_scenario
        resource
      end

      def filter_params
        super.merge(filter_attribute => filter_value)
      end

      def assert_results!
        expect(subject.resources).to match_array([resource])
      end

      def assert_no_results!
        expect(subject.resources).to match_array([])
      end

      context "matches" do
        let(:filter_value) { resource_string.to_s }
        it { assert_results! }
      end

      context "no matches" do
        let(:filter_value) { "foo" }
        it { assert_no_results! }
      end
    end
  end
end

