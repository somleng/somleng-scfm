require "rails_helper"

RSpec.describe StartBroadcast do
  it "starts a broadcast" do
    account = create(:account, :configured_for_broadcasts)
    create(:beneficiary, account:, gender: "M")
    female_beneficiaries = create_list(:beneficiary, 3, account:, gender: "F")
    female_beneficiaries.first(2).each do |beneficiary|
      create(:beneficiary_address, beneficiary:, iso_region_code: "KH-12")
    end
    beneficiary_group = create(:beneficiary_group, account:)
    other_beneficiary_group = create(:beneficiary_group, account:)
    beneficiary_in_group = create(:beneficiary, account:, gender: "M")
    create(:beneficiary_group_membership, beneficiary_group:, beneficiary: beneficiary_in_group)
    create(:beneficiary_group_membership, beneficiary_group: other_beneficiary_group, beneficiary: beneficiary_in_group)
    create(:beneficiary_group_membership, beneficiary_group:, beneficiary: female_beneficiaries.first)

    stub_request(:get, "https://example.com/test.mp3").to_return(status: 200)

    broadcast = create(
      :broadcast,
      audio_url: "https://example.com/test.mp3",
      status: :queued,
      account:,
      error_code: "no_matching_beneficiaries",
      beneficiary_filter: {
        gender: { eq: "F" }
      },
      target_areas: {
        geocode: [
          { iso_region_code: "KH-12" }
        ]
      },
      beneficiary_groups: [ beneficiary_group, other_beneficiary_group ]
    )

    StartBroadcast.call(broadcast)

    expect(broadcast.reload).to have_attributes(
      status: "running",
      error_code: be_blank,
      started_at: be_present,
      audio_file: be_attached
    )
    expect(broadcast.account.events).to include(
      have_attributes(
        type: "broadcast.updated",
        details: hash_including(
          "data" => hash_including(
            "id" => broadcast.id.to_s,
            "type" => "broadcast"
          )
        )
      )
    )
    expect(broadcast.beneficiaries).to contain_exactly(*female_beneficiaries.first(2), beneficiary_in_group)
    expect(broadcast.notifications).to contain_exactly(
      have_attributes(
        beneficiary: female_beneficiaries[0],
        priority: 0,
        phone_number: female_beneficiaries[0].phone_number,
        delivery_attempts_count: 1,
        status: "pending",
        delivery_attempts: contain_exactly(
          have_attributes(
            phone_number: female_beneficiaries[0].phone_number,
            status: "created"
          )
        )
      ),
      have_attributes(
        beneficiary: beneficiary_in_group,
        priority: 0,
        phone_number: beneficiary_in_group.phone_number,
        delivery_attempts_count: 1,
        status: "pending",
        delivery_attempts: contain_exactly(
          have_attributes(
            phone_number: beneficiary_in_group.phone_number,
            status: "created"
          )
        )
      ),
      have_attributes(
        beneficiary: female_beneficiaries[1],
        priority: 1,
        phone_number: female_beneficiaries[1].phone_number,
        delivery_attempts_count: 1,
        status: "pending",
        delivery_attempts: contain_exactly(
          have_attributes(
            phone_number: female_beneficiaries[1].phone_number,
            status: "created"
          )
        )
      )
    )
  end

  it "handles audio channels" do
    account = create(:account)
    create(:beneficiary_address, beneficiary: create(:beneficiary, account:), iso_region_code: "KH-12")

    broadcast = create(
      :broadcast,
      :audio,
      :with_attached_audio,
      status: :queued,
      account:,
      target_areas: {
        geocode: [
          { iso_region_code: [ "KH-12" ] }
        ]
      }
    )

    StartBroadcast.call(broadcast)

    expect(broadcast).to have_attributes(
      status: "running",
      notifications: be_empty
    )
  end

  it "copies the audio file with an extension" do
    broadcast = create(:broadcast, :queued, :with_attached_audio, active_storage_service: :amazon)
    allow(CopyBlobWithExtension).to receive(:call)

    StartBroadcast.call(broadcast)

    expect(CopyBlobWithExtension).to have_received(:call).with(broadcast.audio_file.blob, bucket: "uploads.open-ews.org")
  end

  it "starts a broadcast with only a beneficiary group" do
    account = create(:account, :configured_for_broadcasts)
    beneficiary_group = create(:beneficiary_group, account:)
    beneficiary_in_group = create(:beneficiary, account:)
    create(:beneficiary_group_membership, beneficiary_group:, beneficiary: beneficiary_in_group)
    broadcast = create(:broadcast, :with_attached_audio, account:, status: :queued, beneficiary_groups: [ beneficiary_group ])
    _other_beneficiary = create(:beneficiary, account:)

    StartBroadcast.call(broadcast)

    expect(broadcast.beneficiaries).to contain_exactly(beneficiary_in_group)
  end

  it "handles invalid beneficiary filters" do
    account = create(:account, :configured_for_broadcasts)
    create(:beneficiary, account:)
    broadcast = create(:broadcast, :with_attached_audio, account:, status: :queued, beneficiary_filter: { gender: { eq: "Z" } })

    StartBroadcast.call(broadcast)

    expect(broadcast).to have_attributes(
      status: "errored",
      beneficiaries: be_empty
    )
  end

  it "marks errored when the audio file can't be downloaded" do
    account = create(:account, :configured_for_broadcasts)
    broadcast = create(
      :broadcast,
      account:,
      status: :queued,
      audio_url: "https://example.com/not-found.mp3",
    )
    stub_request(:get, "https://example.com/not-found.mp3").to_return(status: 404)

    StartBroadcast.call(broadcast)

    expect(broadcast).to have_attributes(
      status: "errored",
      error_code: "audio_download_failed"
    )
    expect(broadcast.account.events).to include(have_attributes(type: "broadcast.updated"))
  end

  it "marks errored when the audio file is an invalid format" do
    account = create(:account, :configured_for_broadcasts)
    broadcast = create(
      :broadcast,
      account:,
      status: :queued,
      audio_url: "https://example.com/test.txt",
    )
    stub_request(:get, "https://example.com/test.txt").to_return(status: 200, body: "This is not a valid audio file.")

    StartBroadcast.call(broadcast)

    expect(broadcast).to have_attributes(
      status: "errored",
      error_code: "invalid_audio_file"
    )
    expect(broadcast.account.events).to include(have_attributes(type: "broadcast.updated"))
  end

  it "marks errored when there are no beneficiaries that match the filters" do
    account = create(:account, :configured_for_broadcasts)
    _male_beneficiary = create(:beneficiary, account:, gender: "M")

    broadcast = create(
      :broadcast,
      account:,
      audio_url: "https://example.com/test.mp3",
      status: :queued,
      beneficiary_filter: {
        gender: { eq: "F" }
      }
    )
    stub_request(:get, "https://example.com/test.mp3").to_return(status: 200)

    StartBroadcast.call(broadcast)

    expect(broadcast.reload).to have_attributes(
      status: "errored",
      error_code: "no_matching_beneficiaries",
      audio_file: be_attached
    )
    expect(broadcast.account.events).to include(have_attributes(type: "broadcast.updated"))
  end

  it "marks errored when the account is not yet configured for sending broadcasts" do
    account = create(:account)

    broadcast = create(
      :broadcast,
      account:,
      audio_file: file_fixture("test.mp3"),
      status: :queued,
      beneficiary_filter: {
        gender: { eq: "F" }
      }
    )

    StartBroadcast.call(broadcast)

    expect(broadcast).to have_attributes(
      status: "errored",
      error_code: "account_not_configured_for_channel"
    )
    expect(broadcast.account.events).to include(have_attributes(type: "broadcast.updated"))
  end

  it "handles broadcasts that are not queued" do
    broadcast = create(:broadcast, :errored)

    StartBroadcast.call(broadcast)

    expect(broadcast.reload).to be_errored
  end
end
