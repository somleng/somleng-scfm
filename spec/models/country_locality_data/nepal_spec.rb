require "rails_helper"

module CountryLocalityData
  RSpec.describe Nepal do
    it "returns address localities in Nepal" do
      province = Gaun::Province.all.first
      district = Gaun::District.all.first

      result = CountryLocalityData.locality_data(:NP)

      expect(result).to have_attributes(
        local_language: :ne,
        collection: include(
          have_attributes(
            value: province.code,
            name_en: province.name_en,
            name_local: province.name_ne,
            path: [ province.code ]
          ),
          have_attributes(
            value: district.code,
            name_en: district.name_en,
            name_local: district.name_ne,
            path: [ district.province.code, district.code ]
          )
        )
      )
    end
  end
end
