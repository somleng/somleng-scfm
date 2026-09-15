require "rails_helper"

RSpec.describe CreateBroadcast do
  it "creates a broadcast" do
    account = create(:account, iso_country_code: "US")
    broadcast = CreateBroadcast.call(
      account:,
      channel: "text_message",
      message: "Test message",
      created_via: :api,
      beneficiary_filter: {
        gender: {
          eq: "M"
        }
      },
      target_areas: {
        geocode: [
          { iso_region_code: "US-NY" },
          { iso_region_code: "US-CA", administrative_division_level_2_code: "0201" }
        ]
      }
    )

    expect(broadcast).to have_attributes(
      persisted?: true,
      account: have_attributes(
        events: contain_exactly(
          have_attributes(
            type: "broadcast.created",
            details: hash_including(
              "data" => hash_including(
                "id" => broadcast.id.to_s,
                "type" => "broadcast",
                "attributes" => hash_including(
                  "status" => "pending"
                )
              )
            )
          )
        )
      ),
      channel: "text_message",
      created_via: "api",
      beneficiary_filter: {
        "gender" => {
          "eq" => "M"
        }
      },
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
end
