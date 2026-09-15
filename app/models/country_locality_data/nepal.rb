module CountryLocalityData
  class Nepal
    class << self
      def locality_data
        add_provinces
        add_districts

        collection
      end

      private

      def add_provinces
        Gaun::Province.all.map do |province|
          collection.add(build_locality(province) { [ province.code ] })
        end
      end

      def add_districts
        Gaun::District.all.map do |district|
          collection.add(build_locality(district) { [ district.province.code, district.code ] })
        end
      end

      def build_locality(data, &)
        CountryLocalityData::Locality.new(
          value: data.code,
          name_en: data.name_en,
          name_local: data.name_ne,
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
