class Filter::Attribute::Timestamp < Filter::Attribute::Base
  attr_accessor :timestamp_attribute

  def initialize(options = {}, params = {})
    self.timestamp_attribute = options[:timestamp_attribute]
    super
  end

  def apply
    scope = association_chain.all
    valid_query_mappings.each do |query_mapping, filter_value|
      scope = scope.timestamp_attribute_is(query_mapping, filter_value, timestamp_attribute)
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
        [v, parse_filter_value(filter_value) && filter_value]
      end
    ].compact
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

  def parse_filter_value(raw_value)
    raw_value && DateTime.parse(raw_value) rescue nil
  end
end
