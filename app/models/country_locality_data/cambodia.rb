module CountryLocalityData
  class Cambodia
    class << self
      def locality_data
        add_provinces
        add_districts
        add_communes

        collection
      end

      private

      def add_provinces
        Pumi::Province.all.each do |province|
          collection.add(
            build_locality(province) { [ province.iso3166_2, [ province.iso3166_2 ] ] }
          )
        end
      end

      def add_districts
        Pumi::District.all.each do |district|
          collection.add(
            build_locality(district) { [ district.id, [ district.province.iso3166_2, district.id ] ] }
          )
        end
      end

      def add_communes
        Pumi::Commune.all.each do |commune|
          collection.add(build_locality(commune) { [ commune.id, [ commune.province.iso3166_2, commune.district.id, commune.id ] ] })
        end
      end

      def build_locality(data, &)
        value, path = yield(data)
        CountryLocalityData::Locality.new(
          value:,
          name_en: data.name_latin,
          name_local: data.name_km,
          path:,
          subdivisions: []
        )
      end

      def collection
        @collection ||= Collection.new
      end
    end
  end
end
