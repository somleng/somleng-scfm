RSpec.shared_examples_for "timestamp_attribute_filter" do |*timestamp_attributes|
  timestamp_attributes = %i[created_at updated_at] if timestamp_attributes.empty?

  timestamp_attributes.each do |timestamp_attribute|
    context "filtering by #{timestamp_attribute}" do
      it "filters by the timestamp" do
        resource_timestamp = Time.now.utc
        filterable = create(filterable_factory, timestamp_attribute => resource_timestamp)
        filterable.update_column(timestamp_attribute, resource_timestamp)
        filter_timestamp = resource_timestamp + 1.second

        filter_params = build_filter_params(timestamp_attribute, :before, filter_timestamp)
        filter = build_filter(filter_params)
        expect(filter.resources).to match_array([filterable])

        filter_params = build_filter_params(timestamp_attribute, :after, filter_timestamp)
        filter = build_filter(filter_params)
        expect(filter.resources).to match_array([])

        filter_params = build_filter_params(timestamp_attribute, :or_before, filter_timestamp.to_date)
        filter = build_filter(filter_params)
        expect(filter.resources).to match_array([filterable])

        filter_params = build_filter_params(timestamp_attribute, :or_after, filter_timestamp.to_date)
        filter = build_filter(filter_params)
        expect(filter.resources).to match_array([filterable])

        filter_params = build_filter_params(timestamp_attribute, :before, filter_timestamp.to_date)
        filter = build_filter(filter_params)
        expect(filter.resources).to match_array([])

        filter_params = build_filter_params(timestamp_attribute, :after, filter_timestamp.to_date)
        filter = build_filter(filter_params)
        expect(filter.resources).to match_array([])

        filter_params = build_filter_params(timestamp_attribute, :after, "foo")
        filter = build_filter(filter_params)
        expect(filter.resources).to match_array([filterable])
      end

      def build_filter(filter_params)
        described_class.new({ association_chain: association_chain }, filter_params)
      end

      def build_filter_params(timestamp_attribute, comparator, timestamp)
        {
          :"#{timestamp_attribute}_#{comparator}" => timestamp.to_s
        }
      end
    end
  end
end
