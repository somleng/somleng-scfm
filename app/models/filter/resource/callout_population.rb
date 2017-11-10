class Filter::Resource::CalloutPopulation < Filter::Resource::Base
  def self.attribute_filters
    super << :contact_filter_params_attribute_filter
  end

  def contact_filter_params_attribute_filter
    @contact_filter_params_attribute_filter ||= Filter::Attribute::ContactFilterParams.new(options, params)
  end
end

