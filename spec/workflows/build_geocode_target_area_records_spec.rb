require "rails_helper"

RSpec.describe BuildGeocodeTargetAreaRecords do
  it "builds target area records" do
    target_areas = build_target_areas(
      { iso_region_code: "US-AL" },
      { iso_region_code: "US-NY", administrative_division_level_2_code: "0201" }
    )

    result = BuildGeocodeTargetAreaRecords.call(target_areas, locality_data: locality_data_for("US"))

    expect(result).to contain_exactly(
      { administrative_level: 1, geocode: "US-AL", path: [ "US-AL" ] },
      { administrative_level: 2, geocode: "0201", path: [ "US-NY", "0201" ] }
    )
  end

  it "builds expanded target area records" do
    target_areas = build_target_areas(
      { iso_region_code: "KH-1" },
      { iso_region_code: "KH-2", administrative_division_level_2_code: "0201" }
    )

    result = BuildGeocodeTargetAreaRecords.call(target_areas, locality_data: locality_data_for("KH"))

    expect(result).to include(
      { administrative_level: 1, geocode: "KH-1", path: [ "KH-1" ] },
      { administrative_level: 2, geocode: "0201", path: [ "KH-2", "0201" ] },
      { administrative_level: 2, geocode: "0102", path: [ "KH-1", "0102" ] },
      { administrative_level: 3, geocode: "010201", path: [ "KH-1", "0102", "010201" ] },
      { administrative_level: 3, geocode: "020101", path: [ "KH-2", "0201", "020101" ] }
    )
    expect(result).not_to include(
      include(geocode: "KH-2"),
      include(geocode: "KH-12")
    )
  end

  def build_target_areas(*areas)
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :target_areas, TargetAreaDataType.new
    end

    instance = klass.new
    instance.target_areas = { geocode: areas }
    instance.target_areas.geocode
  end

  def locality_data_for(country_code)
    CountryLocalityData.locality_data(country_code).collection
  end
end
