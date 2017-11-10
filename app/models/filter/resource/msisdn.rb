class Filter::Resource::Msisdn < Filter::Resource::Base
  def self.attribute_filters
    super << :msisdn_attribute_filter
  end

  private

  def msisdn_attribute_filter
    @msisdn_attribute_filter ||= Filter::Attribute::Msisdn.new(options, params)
  end
end
