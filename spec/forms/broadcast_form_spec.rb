require "rails_helper"

RSpec.describe BroadcastForm do
  it "handles initialization" do
    broadcast = create(
      :broadcast,
      channel: :voice_call,
      beneficiary_filter: {
        gender: { eq: "M" },
        "address.iso_region_code": { eq: "KH-1" }
      }
    )

    form = BroadcastForm.initialize_with(broadcast)

    expect(form).to have_attributes(
      channel: "voice_call",
      beneficiary_filter: have_attributes(
        gender: have_attributes(
          operator: "eq",
          value: "M"
        ),
        iso_region_code: have_attributes(
          operator: "eq",
          value: "KH-1"
        )
      )
    )
  end

  it "handles new records" do
    account = create(:account)
    user = create(:user, account:)

    form = BroadcastForm.new(
      account:,
      audio_file: file_fixture("test.mp3"),
      channel: :voice_call,
      beneficiary_filter: { gender: { operator: "eq", value: "M" } },
      geocode_target_areas: [
        { iso_region_code: "KH-1" }
      ],
      created_by: user
    )

    expect(form).to have_attributes(
      account:,
      channel: "voice_call",
      beneficiary_filter: have_attributes(
        gender: have_attributes(
          operator: "eq",
          value: "M"
        )
      )
    )

    expect(form.save).to be_truthy

    expect(form.object).to have_attributes(
      persisted?: true,
      channel: "voice_call",
      audio_file: be_attached,
      beneficiary_filter: {
        "gender" => { "eq" => "M" }
      },
      target_areas: have_attributes(
        geocode: contain_exactly(
          have_attributes(path: [ "KH-1" ])
        )
      ),
      created_via: "dashboard",
      created_by: user
    )
  end

  it "handles existing records" do
    account = create(:account)
    user = create(:user, account:)
    broadcast = create(
      :broadcast,
      :text_message,
      account:,
      beneficiary_filter: { gender: { operator: "eq", value: "M" } },
      target_areas: { geocode: [ { iso_region_code: "KH-1" } ] }
    )
    form = BroadcastForm.initialize_with(broadcast)
    form.assign_attributes(
      updated_by: user,
      message: "New message",
      beneficiary_filter: { gender: { operator: "eq", value: "F" } },
      geocode_target_areas: [
        { iso_region_code: "KH-2", administrative_division_level_2_code: "0201" }
      ]
    )

    expect(form.save).to be_truthy

    expect(form.object).to have_attributes(
      persisted?: true,
      message: "New message",
      updated_by: user,
      beneficiary_filter: {
        "gender" => { "eq" => "F" }
      },
      target_areas: have_attributes(
        geocode: contain_exactly(
          have_attributes(path: [ "KH-2", "0201" ])
        )
      )
    )
  end

  it "ensures the channel cannot be updated" do
    broadcast = create(:broadcast, :voice_call)
    form = BroadcastForm.new(account: broadcast.account, object: broadcast, channel: "text_message")

    form.save

    expect(broadcast.reload.channel).to eq("voice_call")
  end

  it "validates the beneficiary groups" do
    account = create(:account)
    beneficiary_groups = create_list(:beneficiary_group, 11, account:)
    form = BroadcastForm.new(
      account:,
      channel: "voice_call",
      beneficiary_groups: beneficiary_groups.pluck(:id)
    )

    form.valid?

    expect(form.errors[:beneficiary_groups]).to be_present

    form = BroadcastForm.new(
      account:,
      channel: "audio",
      beneficiary_groups: beneficiary_groups.pluck(:id).first(1)
    )

    form.valid?

    expect(form.errors[:beneficiary_groups]).to be_present
  end

  it "validates the beneficiary filter" do
    account = create(:account)

    form = BroadcastForm.new(
      account:,
      channel: "audio",
      beneficiary_filter: { gender: { operator: "eq", value: "M" } },
    )

    form.valid?

    expect(form.errors[:beneficiary_filter]).to be_present
  end

  it "validates the channel" do
    account = create(:account, supported_channels: [ "text_message" ])
    form = BroadcastForm.new(account:, channel: "voice_call")

    form.valid?

    expect(form.errors[:channel]).to be_present
  end

  it "validates the audio file presence for voice and audio broadcasts" do
    account = create(:account)
    voice_call_form = BroadcastForm.new(account:, channel: "voice_call")
    audio_form = BroadcastForm.new(account:, channel: "audio")

    voice_call_form.valid?
    audio_form.valid?

    expect(voice_call_form.errors[:audio_file]).to be_present
    expect(audio_form.errors[:audio_file]).to be_present
  end

  it "validates the message presence for message broadcasts" do
    account = create(:account)
    form = BroadcastForm.new(account:, channel: "text_message")

    form.valid?

    expect(form.errors[:message]).to be_present
  end

  it "validates the audio file size" do
    account = create(:account)
    form = BroadcastForm.new(account:, channel: "audio", audio_file: file_fixture("big_file.mp3"))

    form.valid?

    expect(form.errors[:audio_file]).to be_present
  end

  it "validates the geocode target areas" do
    form = BroadcastForm.new(
      account: create(:account),
      geocode_target_areas: "foobar"
    )

    form.valid?

    expect(form.errors[:geocode_target_areas]).to be_present

    form = BroadcastForm.new(
      account: create(:account),
      geocode_target_areas: ""
    )

    form.valid?

    expect(form.errors[:geocode_target_areas]).to be_empty
  end
end
