require "rails_helper"

module CountryLocalityData
  RSpec.describe Myanmar do
    it "returns address localities in Myanmar" do
      result = CountryLocalityData.locality_data(:MM)

      expect(result).to have_attributes(
        local_language: :my,
        collection: include(
          have_attributes(
            value: "MM-11",
            name_en: "Kachin",
            name_local: "ကချင်ပြည်နယ်",
            path: [ "MM-11" ]
          ),
          have_attributes(
            value: "MMR001D001",
            name_en: "Myitkyina",
            name_local: "မြစ်ကြီးနားခရိုင်",
            path: [ "MM-11", "MMR001D001" ]
          ),
          have_attributes(
            value: "MMR001002",
            name_en: "Waingmaw",
            name_local: "ဝိုင်းမော်",
            path: [ "MM-11", "MMR001D001", "MMR001002" ]
          ),
          have_attributes(
            value: "MMR001002006",
            name_en: "Mong Nar",
            name_local: "မိုင်းနား",
            path: [ "MM-11", "MMR001D001", "MMR001002", "MMR001002006" ]
          ),
          have_attributes(
            value: "MMR001002006216830",
            name_en: "Mat Khaw Ti",
            name_local: "မတ်ခေါတီ",
            path: [ "MM-11", "MMR001D001", "MMR001002", "MMR001002006", "MMR001002006216830" ]
          )
        )
      )
    end
  end
end
