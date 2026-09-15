require "rails_helper"

module CountryLocalityData
  RSpec.describe Cambodia do
    it "returns address localities in Cambodia" do
      province = Pumi::Province.all.first
      district = Pumi::District.all.first
      commune = Pumi::Commune.all.first

      result = CountryLocalityData.locality_data(:KH)

      expect(result).to have_attributes(
        local_language: :km,
        collection: include(
          have_attributes(
            value: province.iso3166_2,
            name_en: province.name_en,
            name_local: province.name_km,
            path: [ province.iso3166_2 ]
          ),
          have_attributes(
            value: district.id,
            name_en: district.name_en,
            name_local: district.name_km,
            path: [ district.province.iso3166_2, district.id ]
          ),
          have_attributes(
            value: commune.id,
            name_en: commune.name_en,
            name_local: commune.name_km,
            path: [ commune.province.iso3166_2, district.id, commune.id ]
          )
        )
      )
    end
  end
end
