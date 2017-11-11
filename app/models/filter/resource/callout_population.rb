class Filter::Resource::CalloutPopulation < Filter::Resource::Base
  def self.attribute_filters
    super << :contact_filter_params_attribute_filter
  end

  private

  def contact_filter_params_attribute_filter
    @contact_filter_params_attribute_filter ||= Filter::Attribute::JSON.new(
      {:json_attribute => :contact_filter_params}.merge(options), params
    )
  end
end

