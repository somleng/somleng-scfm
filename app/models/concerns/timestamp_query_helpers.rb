module TimestampQueryHelpers
  extend ActiveSupport::Concern

  class_methods do
    def timestamp_attribute_is(comparator, value, timestamp_attribute)
      query_value = DateTime.parse(value)
      query_value = query_value.to_date if query_value == Date.parse(value)

      arel_timestamp_attribute = if query_value.class == Date
                                   Arel::Nodes::NamedFunction.new(
                                     "CAST", [arel_table[timestamp_attribute].as("DATE")]
                                   )
                                 else
                                   arel_table[timestamp_attribute]
                                 end

      where(arel_timestamp_attribute.public_send(comparator, query_value))
    end
  end
end
