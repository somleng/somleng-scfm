require "rails_helper"

RSpec.describe UpdateBroadcast do
  it "updates a broadcast" do
    broadcast = create(:broadcast, :pending, account: create(:account, iso_country_code: "US"))
    create(:geocode_target_area, broadcast:, path: [ "US-AL" ])

    UpdateBroadcast.call(
      broadcast,
      target_areas: {
        geocode: [
          { iso_region_code: "US-NY" },
          { iso_region_code: "US-CA", administrative_division_level_2_code: "0201" }
        ]
      }
    )

    expect(broadcast.reload).to have_attributes(
      geocode_target_areas: contain_exactly(
        have_attributes(
          administrative_level: 1,
          geocode: "US-NY",
          path: [ "US-NY" ]
        ),
        have_attributes(
          administrative_level: 2,
          geocode: "0201",
          path: [ "US-CA", "0201" ]
        )
      )
    )
  end

  it "updates the broadcast state" do
    broadcast = create(:broadcast, :running)

    UpdateBroadcast.call(broadcast, desired_status: :completed)

    expect(broadcast).to have_attributes(
      status: "completed",
      account: have_attributes(
        events: contain_exactly(
          have_attributes(
            type: "broadcast.updated",
          )
        )
      )
    )
  end

  it "sets started by" do
    broadcast = create(:broadcast, :pending)
    user = create(:user, account: broadcast.account)

    UpdateBroadcast.call(broadcast, desired_status: :queued, updated_by: user)

    expect(broadcast).to have_attributes(status: "queued", started_by: user, updated_by: user)
  end

  it "sets stopped by" do
    broadcast = create(:broadcast, :running)
    user = create(:user, account: broadcast.account)

    UpdateBroadcast.call(broadcast, desired_status: :stopped, updated_by: user)

    expect(broadcast).to have_attributes(status: "stopped", stopped_by: user, updated_by: user)
  end

  it "raises an error when the desired status is invalid" do
    broadcast = create(:broadcast, :pending)

    expect { UpdateBroadcast.call(broadcast, desired_status: :stopped) }.to raise_error(UpdateBroadcast::InvalidStateTransitionError)
  end
end
