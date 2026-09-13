require "rails_helper"

RSpec.describe TargetAreaDataType do
  it "handles parsing target area data" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :target_areas, TargetAreaDataType.new
    end

    expect(
      klass.new(target_areas: {}).target_areas
    ).to have_attributes(geocode: [])

    result = klass.new(
      target_areas: {
        "geocode" => [
          { "iso_region_code" => "KH-1" },
          { "administrative_division_level_2_code" => "0201", "iso_region_code" => "KH-2" }
        ]
      }
    ).target_areas

    expect(result).to have_attributes(
      as_json: eq(
        "geocode" => [
          { "iso_region_code" => "KH-1" },
          { "iso_region_code" => "KH-2", "administrative_division_level_2_code" => "0201" }
        ]
      ),
      geocode: contain_exactly(
        have_attributes(
          level: 1,
          division: have_attributes(geocode: "KH-1"),
          hierarchy: match(
            [
              have_attributes(
                field_name: "iso_region_code",
                geocode: "KH-1",
                level: 1
              )
            ]
          )
        ),
        have_attributes(
          level: 2,
          division: have_attributes(geocode: "0201"),
          hierarchy: match(
            [
              have_attributes(
                field_name: "iso_region_code",
                geocode: "KH-2",
                level: 1
              ),
              have_attributes(
                field_name: "administrative_division_level_2_code",
                geocode: "0201",
                level: 2
              )
            ]
          )
        )
      )
    )
  end
end
