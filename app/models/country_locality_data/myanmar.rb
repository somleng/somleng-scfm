module CountryLocalityData
  class Myanmar
    class << self
      def locality_data
        add_provinces
        add_districts
        add_towns
        add_village_tracts
        add_villages

        collection
      end

      private

      def add_provinces
        collection.add(
          build_locality(
            value: "MM-11",
            name_en: "Kachin",
            name_local: "ကချင်ပြည်နယ်",
            path: [ "MM-11" ]
          )
        )
      end

      def add_districts
        collection.add(
          build_locality(
            value: "MMR001D001",
            name_en: "Myitkyina",
            name_local: "မြစ်ကြီးနားခရိုင်",
            path: [ "MM-11", "MMR001D001" ]
          )
        )
      end

      def add_towns
        collection.add(
          build_locality(
            value: "MMR001002",
            name_en: "Waingmaw",
            name_local: "ဝိုင်းမော်",
            path: [ "MM-11", "MMR001D001", "MMR001002" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001003",
            name_en: "Injangyang",
            name_local: "အင်ဂျန်းယန်",
            path: [ "MM-11", "MMR001D001", "MMR001003" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001005",
            name_en: "Chipwi",
            name_local: "ချီ​ဖွေ",
            path: [ "MM-11", "MMR001D001", "MMR001005" ]
          )
        )
      end

      def add_village_tracts
        collection.add(
          build_locality(
            value: "MMR001002006",
            name_en: "Mong Nar",
            name_local: "မိုင်းနား",
            path: [ "MM-11", "MMR001D001", "MMR001002", "MMR001002006" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001002014",
            name_en: "Nawng Ching",
            name_local: "နောင်ချိန်း",
            path: [ "MM-11", "MMR001D001", "MMR001002", "MMR001002014" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001003002",
            name_en: "Shagri Bum",
            name_local: "ရှဂရီဘွမ်",
            path: [ "MM-11", "MMR001D001", "MMR001003", "MMR001003002" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001003006",
            name_en: "In Dung Yang",
            name_local: "အင်ဒုံးယန်",
            path: [ "MM-11", "MMR001D001", "MMR001003", "MMR001003006" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001005015",
            name_en: "Man Dungt",
            name_local: "မန့်ဒုန့်",
            path: [ "MM-11", "MMR001D001", "MMR001005", "MMR001005015" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001005004",
            name_en: "Myaw Maw Par",
            name_local: "မျောမောပါ",
            path: [ "MM-11", "MMR001D001", "MMR001005", "MMR001005004" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001005701",
            name_en: "Chipwi",
            name_local: "ချီ​ဖွေ",
            path: [ "MM-11", "MMR001D001", "MMR001005", "MMR001005701" ]
          )
        )
      end

      def add_villages
        collection.add(
          build_locality(
            value: "MMR001002006216830",
            name_en: "Mat Khaw Ti",
            name_local: "မတ်ခေါတီ",
            path: [ "MM-11", "MMR001D001", "MMR001002", "MMR001002006", "MMR001002006216830" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001002006216832",
            name_en: "La Bang",
            name_local: "လဘန်",
            path: [ "MM-11", "MMR001D001", "MMR001002", "MMR001002006", "MMR001002006216832" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001002014165751",
            name_en: "Nawng Ching",
            name_local: "နောင်ချိန်း",
            path: [ "MM-11", "MMR001D001", "MMR001002", "MMR001002014", "MMR001002014165751" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001003002165913",
            name_en: "Aung Ra",
            name_local: "အောင်ရာ",
            path: [ "MM-11", "MMR001D001", "MMR001003", "MMR001003002", "MMR001003002165913" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001003006C220400",
            name_en: "U Lawng Yang",
            name_local: "အူလောန်ယန်",
            path: [ "MM-11", "MMR001D001", "MMR001003", "MMR001003006", "MMR001003006C220400" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001003006220401",
            name_en: "Ju Ba Li",
            name_local: "‌ဂျူဗလီ",
            path: [ "MM-11", "MMR001D001", "MMR001003", "MMR001003006", "MMR001003006220401" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001005015166321",
            name_en: "Man Dungt",
            name_local: "မန့်ဒုန့်",
            path: [ "MM-11", "MMR001D001", "MMR001005", "MMR001005015", "MMR001005015166321" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001005004220455",
            name_en: "Myaw Maw Par",
            name_local: "မျောမောပါ",
            path: [ "MM-11", "MMR001D001", "MMR001005", "MMR001005004", "MMR001005004220455" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001005701501",
            name_en: "Yit Law Hkaung",
            name_local: "ရစ်လောခေါင်ရပ်ကွက်",
            path: [ "MM-11", "MMR001D001", "MMR001005", "MMR001005701", "MMR001005701501" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001005701502",
            name_en: "Oke Kat",
            name_local: "ဥက္ကပ်ရပ်ကွက်",
            path: [ "MM-11", "MMR001D001", "MMR001005", "MMR001005701", "MMR001005701502" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001005701503",
            name_en: "Ba Leit Dan",
            name_local: "ဘာလဲ့ဒမ်ရပ်ကွက်",
            path: [ "MM-11", "MMR001D001", "MMR001005", "MMR001005701", "MMR001005701503" ]
          )
        )

        collection.add(
          build_locality(
            value: "MMR001005701504",
            name_en: "Kan Paing Yan",
            name_local: "ကန်ပိုင်ယံရပ်ကွက်",
            path: [ "MM-11", "MMR001D001", "MMR001005", "MMR001005701", "MMR001005701504" ]
          )
        )
      end

      def collection
        @collection ||= Collection.new
      end

      def build_locality(**)
        CountryLocalityData::Locality.new(subdivisions: [], **)
      end
    end
  end
end
