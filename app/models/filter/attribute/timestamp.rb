class Filter::Attribute::Timestamp < Filter::Attribute::Base
  attr_accessor :timestamp_attribute

  def initialize(options = {}, params = {})
    self.timestamp_attribute = options[:timestamp_attribute]
    super
  end

  def apply
    scope = association_chain.all
    valid_query_mappings.each do |query_mapping, query_values|
      raw_query_value, datetime_query_value = query_values
      arel_datetime_attribute = date_given?(raw_query_value) ? cast_as_date : association_chain.arel_table[timestamp_attribute]
      scope = scope.where(arel_datetime_attribute.public_send(query_mapping, datetime_query_value))
    end
    scope
  end

  def apply?
    valid_query_mappings.any?
  end

  private

  def valid_query_mappings
    @valid_query_mappings ||= validate_query_mappings
  end

  def validate_query_mappings
    Hash[
      filter_query_mappings.map do |k, v|
        filter_value = params[filter_param_key(k)]
        timestamp_filter_value = parse_filter_value(filter_value)
        [v, timestamp_filter_value && [filter_value, timestamp_filter_value]]
      end
    ].compact
  end

  def cast_as_date
    Arel::Nodes::NamedFunction.new('CAST', [association_chain.arel_table[timestamp_attribute].as('DATE')])
  end

  def filter_query_mappings
    {
      :before => :lt,
      :or_before => :lteq,
      :after => :gt,
      :or_after => :gteq
    }
  end

  def filter_param_key(key)
    [timestamp_attribute, key].join("_").to_sym
  end

  def date_given?(raw_value)
    DateTime.parse(raw_value) == Date.parse(raw_value)
  end

  def parse_filter_value(raw_value)
    raw_value && DateTime.parse(raw_value) rescue nil
  end
end
