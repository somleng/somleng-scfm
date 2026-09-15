class GeocodeTargetArea < ApplicationRecord
  belongs_to :broadcast

  def self.outside(administrative_level:, geocode:)
    where(administrative_level:).where.not(geocode:)
  end
end
