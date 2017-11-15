RSpec.shared_examples_for "timestamp_attribute_filter" do |*timestamp_attributes|
  timestamp_attributes = [:created_at, :updated_at] if timestamp_attributes.empty?

  timestamp_attributes.each do |timestamp_attribute|
    context "filtering by #{timestamp_attribute}" do
      let(:resource_timestamp) { Time.now.utc }
      let(:resource) {
        filterable = create(filterable_factory, timestamp_attribute => resource_timestamp)
        filterable.update_column(timestamp_attribute, resource_timestamp)
        filterable
      }

      def setup_scenario
        resource
      end

      def filter_params
        super.merge(filter_param => timestamp_filter_value.to_s)
      end

      def assert_results!
        expect(subject.resources).to match_array([resource])
      end

      def assert_no_results!
        expect(subject.resources).to match_array([])
      end

      context "filter parameter is a time" do
        let(:timestamp_filter_value) { resource_timestamp + 1.second }

        context "#{timestamp_attribute}_before" do
          let(:filter_param) { :"#{timestamp_attribute}_before" }
          it { assert_results! }
        end

        context "#{timestamp_attribute}_after" do
          let(:filter_param) { :"#{timestamp_attribute}_after" }
          it { assert_no_results! }
        end
      end

      context "filter parameter is a date" do
        let(:timestamp_filter_value) { resource_timestamp.to_date }

        context "#{timestamp_attribute}_or_before" do
          let(:filter_param) { :"#{timestamp_attribute}_or_before" }
          it { assert_results! }
        end

        context "#{timestamp_attribute}_or_after" do
          let(:filter_param) { :"#{timestamp_attribute}_or_after" }
          it { assert_results! }
        end

        context "#{timestamp_attribute}_before" do
          let(:filter_param) { :"#{timestamp_attribute}_before" }
          it { assert_no_results! }
        end

        context "#{timestamp_attribute}_after" do
          let(:filter_param) { :"#{timestamp_attribute}_after" }
          it { assert_no_results! }
        end
      end

      context "filter parameter is invalid" do
        let(:timestamp_filter_value) { "foo" }
        let(:filter_param) { :"#{timestamp_attribute}_after" }
        it { assert_results! }
      end
    end
  end
end
