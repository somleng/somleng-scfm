module Filter
  module Resource
    class BatchOperation < Filter::Resource::Base
      def self.attribute_filters
        super << :parameters_attribute_filter
      end

      private

      def parameters_attribute_filter
        @parameters_attribute_filter ||= Filter::Attribute::JSON.new(
          { json_attribute: :parameters }.merge(options), params
        )
      end

      def filter_params
        params.slice(:callout_id, :status)
      end
    end
  end
end
