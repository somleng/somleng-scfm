require "rails_helper"

module CountryLocalityData
  RSpec.describe Laos do
    it "returns address localities in Laos" do
      province = Baan::Province.all.first
      district = Baan::District.all.first
      village = Baan::Village.all.first

      result = CountryLocalityData.locality_data(:LA)

      expect(result).to have_attributes(
        local_language: :lo,
        collection: include(
          have_attributes(
            value: province.code,
            name_en: province.name_en,
            name_local: province.name_lo,
            path: [ province.code ]
          ),
          have_attributes(
            value: district.code,
            name_en: district.name_en,
            name_local: district.name_lo,
            path: [ district.province.code, district.code ]
          ),
          have_attributes(
            value: village.code,
            name_en: village.name_en,
            name_local: village.name_lo,
            path: [ village.district.province.code, village.district.code, village.code ]
          )
        )
      )
    end
  end
end
