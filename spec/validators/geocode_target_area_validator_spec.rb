require "rails_helper"

RSpec.describe GeocodeTargetAreaValidator do
  it "validates the geocode target areas" do
    validator = GeocodeTargetAreaValidator.new

    expect(validator).not_to be_valid("invalid")
    expect(validator).not_to be_valid({})
    expect(validator).not_to be_valid({ foobar: "KH-1" })
    expect(validator).not_to be_valid(
      {
        iso_region_code: "KH-1",
        administrative_division_level_2_code: "",
        administrative_division_level_3_code: "010201"
      }
    )
    expect(validator).to be_valid(
      {
        iso_region_code: "KH-1",
        administrative_division_level_2_code: "0102",
        administrative_division_level_3_code: "010201"
      }
    )
  end
end
