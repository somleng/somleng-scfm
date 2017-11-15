class Filter::Resource::Base < Filter::Base
  def resources
    scope = association_chain.where(or_filter_params)
    self.class.attribute_filters.each do |attribute_filter_name|
      attribute_filter = send(attribute_filter_name)
      scope = scope.merge(attribute_filter.apply) if attribute_filter.apply?
    end
    scope
  end

  private

  def or_filter_params
    Hash[filter_params.to_h.map { |k, v| [k, split_filter_values(v)] }]
  end

  def filter_params
    {}
  end

  def metadata_attribute_filter
    @metadata_attribute_filter ||= Filter::Attribute::JSON.new(
      {:json_attribute => :metadata}.merge(options), params
    )
  end

  def created_at_attribute_filter
    @created_at_attribute_filter ||= Filter::Attribute::Timestamp.new(
      {:timestamp_attribute => :created_at}.merge(options), params
    )
  end

  def updated_at_attribute_filter
    @updated_at_attribute_filter ||= Filter::Attribute::Timestamp.new(
      {:timestamp_attribute => :updated_at}.merge(options), params
    )
  end

  def self.attribute_filters
    [:metadata_attribute_filter, :created_at_attribute_filter, :updated_at_attribute_filter]
  end
end
