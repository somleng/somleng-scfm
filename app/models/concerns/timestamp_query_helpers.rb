module TimestampQueryHelpers
  extend ActiveSupport::Concern

  class_methods do
    def timestamp_attribute_is(comparator, value, timestamp_attribute)
      arel_timestamp_attribute = if value.is_a?(Date)
                                   Arel::Nodes::NamedFunction.new(
                                     "CAST", [ arel_table[timestamp_attribute].as("DATE") ]
                                   )
      else
                                   arel_table[timestamp_attribute]
      end

      where(arel_timestamp_attribute.public_send(comparator, value))
    end
  end
end
