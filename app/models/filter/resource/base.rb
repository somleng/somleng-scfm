class Filter::Resource::Base < Filter::Base
  def resources
    scope = association_chain.where(filter_params)
    self.class.attribute_filters.each do |attribute_filter_name|
      attribute_filter = send(attribute_filter_name)
      scope = scope.merge(attribute_filter.apply) if attribute_filter.apply?
    end
    scope
  end

  private

  def filter_params
    {}
  end

  def metadata_attribute_filter
    @metadata_attribute_filter ||= Filter::Attribute::JSON.new(
      {:json_attribute => :metadata}.merge(options), params
    )
  end

  def self.attribute_filters
    [:metadata_attribute_filter]
  end
end
