class Filter::Resource::Contact < Filter::Resource::Msisdn
  def self.attribute_filters
    super << :has_locations_in
  end

  private

  def has_locations_in
    Filter::Scope::HasLocationsIn.new(options, params)
  end
end
