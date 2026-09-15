require "rails_helper"

RSpec.describe Broadcast do
  it "validates the number of beneficiary groups" do
    broadcast = build(:broadcast)
    broadcast.beneficiary_groups = 11.times.map { build(:beneficiary_group, account: broadcast.account) }

    expect(broadcast.valid?).to be(false)
    expect(broadcast.errors[:beneficiary_groups]).to be_present
  end

  describe ".geocode_target_areas_equal" do
    it "returns broadcasts whose target areas are all within the specified administrative division" do
      matching_broadcast = create(:broadcast)
      non_matching_broadcast = create(:broadcast)
      _broadcast_with_no_target_areas = create(:broadcast)
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1" ]
      )
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1", "0102" ]
      )
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1", "0102", "010201" ]
      )
      create(
        :geocode_target_area,
        broadcast: non_matching_broadcast,
        path: [ "KH-2" ]
      )

      result = Broadcast.geocode_target_areas_equal(administrative_level: 1, geocode: [ "KH-1" ])

      expect(result).to contain_exactly(matching_broadcast)
    end
  end

  describe ".geocode_target_areas_contain" do
    it "returns broadcasts whose target areas contain the specified administrative divisions" do
      matching_broadcast = create(:broadcast)
      non_matching_broadcast = create(:broadcast)

      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1" ]
      )
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1", "0102" ],
      )
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1", "0102", "010201" ]
      )
      create(
        :geocode_target_area,
        broadcast: non_matching_broadcast,
        path: [ "KH-2" ]
      )

      result = Broadcast.geocode_target_areas_contain(
        administrative_level: 3, geocode: [ "010201", "010202" ]
      )

      expect(result).to contain_exactly(matching_broadcast)
    end
  end
end
