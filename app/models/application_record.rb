class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.timestamp_attribute_is(comparator, value, timestamp_attribute)
    if value.is_a?(String)
      query_value = DateTime.parse(value)
      query_value = query_value.to_date if query_value == Date.parse(value)
    else
      query_value = value
    end

    arel_timestamp_attribute = query_value.class == Date ? cast_as_date(timestamp_attribute) : arel_table[timestamp_attribute]

    where(arel_timestamp_attribute.public_send(comparator, query_value))
  end

  def self.cast_as_date(attribute)
    if database_adapter_helper.adapter_sqlite?
      Arel::Nodes::NamedFunction.new('DATE', [arel_table[attribute]])
    else
      Arel::Nodes::NamedFunction.new('CAST', [arel_table[attribute].as('DATE')])
    end
  end

  def self.database_adapter_helper
    @database_adapter_helper ||= DatabaseAdapterHelper.new
  end
end
