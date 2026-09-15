module CountryLocalityData
  class Laos
    class << self
      def locality_data
        add_provinces
        add_districts
        add_villages

        collection
      end

      private

      def add_provinces
        Baan::Province.all.map do |province|
          collection.add(build_locality(province) { [ province.code ] })
        end
      end

      def add_districts
        Baan::District.all.map do |district|
          collection.add(build_locality(district) { [ district.province.code, district.code ] })
        end
      end

      def add_villages
        Baan::Village.all.map do |village|
          collection.add(build_locality(village) { [ village.province.code, village.district.code, village.code ] })
        end
      end

      def build_locality(data, &)
        CountryLocalityData::Locality.new(
          value: data.code,
          name_en: data.name_en,
          name_local: data.name_lo,
          path: yield(data),
          subdivisions: []
        )
      end

      def collection
        @collection ||= Collection.new
      end
    end
  end
end
