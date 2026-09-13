require "rails_helper"

RSpec.describe "Broadcasts" do
  it "list broadcasts", :js do
    user = create(:user)
    pending_broadcast = create(
      :broadcast,
      :pending,
      :voice_call,
      name: "My broadcast 1",
      account: user.account
    )
    completed_broadcast = create(
      :broadcast,
      :completed,
      :text_message,
      name: "My broadcast 2",
      account: user.account
    )
    other_broadcast = create(:broadcast, name: "My broadcast 3")

    account_sign_in(user)
    visit dashboard_broadcasts_path

    expect(page).to have_title("Broadcasts")
    expect(page).to have_content("My broadcast 1")
    expect(page).to have_content("My broadcast 2")
    expect(page).to have_no_content("My broadcast 3")

    click_on "Filters"
    select_filter("Status", operator: "Equals", select: "Pending")
    select_filter("Channels", operator: "Contains", select: "Voice call")
    click_on "Apply Filters"

    expect(page).to have_content_tag_for(pending_broadcast)
    expect(page).not_to have_content_tag_for(completed_broadcast)
    expect(page).not_to have_content_tag_for(other_broadcast)
  end

  it "create a voice broadcast", :js do
    account = create(:account, iso_country_code: "KH", supported_channels: [ "voice_call" ])
    user = create(:user, :owner, account:)
    create_beneficiary_group(name: "My group", account:)
    create_beneficiary_group(name: "My other group", account:)

    account_sign_in(user)
    visit new_dashboard_broadcast_path

    expect(page).to have_select("Channel", options: [ "Voice call" ])

    fill_in("Name", with: "My broadcast")
    select("Voice call", from: "Channel")
    attach_file("Audio file", file_fixture("test.mp3"))
    select_list("My group", "My other group", from: "Beneficiary groups")
    select_filter("Gender", operator: "Equals", select: "Male")
    select_filter("Target areas")
    select_tree("Banteay Meanchey", "Mongkol Borey", "Banteay Neang")

    click_on("Create Broadcast")

    expect(page).to have_content("Broadcast was successfully created.")
    expect(page).to have_content("My broadcast")
    expect(page).to have_content("My group")
    expect(page).to have_content("My other group")
    expect(page).to have_link(user.name, href: dashboard_settings_user_path(user))
    within("#beneficiary_filter_gender") do
      expect(page).to have_field(with: "Gender")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "Male")
    end
    within("#beneficiary_filter_administrative_division_level_3_code") do
      expect(page).to have_content("Banteay Meanchey")
      expect(page).to have_content("Mongkol Borey")
      expect(page).to have_content("Banteay Neang")
    end
  end

  it "create a text message broadcast", :js do
    account = create(:account, iso_country_code: "KH")
    user = create(:user, account:)

    account_sign_in(user)
    visit new_dashboard_broadcast_path
    select("Text message", from: "Channel")
    fill_in("Message", with: "Test message")
    select_filter("Gender", operator: "Equals", select: "Male")
    click_on("Create Broadcast")

    expect(page).to have_content("Broadcast was successfully created.")
    expect(page).to have_content("Text message")
    expect(page).to have_content("Test message")
    expect(page).to have_selector(".notification-stats")
  end

  it "create an audio broadcast", :js do
    account = create(:account)
    user = create(:user, account:)

    account_sign_in(user)
    visit new_dashboard_broadcast_path
    select("Audio", from: "Channel")
    attach_file("Audio file", file_fixture("test.mp3"))
    click_on("Create Broadcast")

    expect(page).to have_content("Broadcast was successfully created.")
    expect(page).to have_content("Audio")
    expect(page).to have_no_selector(".notification-stats")
  end

  it "create a broadcast from an unsupported country", :js do
    account = create(:account, iso_country_code: "US")
    user = create(:user, account:)

    account_sign_in(user)
    visit new_dashboard_broadcast_path

    select("Voice", from: "Channel")
    attach_file("Audio file", file_fixture("test.mp3"))
    select_filter("Country", operator: "Equals", select: "United States of America")
    select_filter("ISO region code", operator: "Equals", fill_in: "US-AL")
    select_filter("Administrative division level 2 code", operator: "Equals", fill_in: "001")
    select_filter("Administrative division level 2 name", operator: "Starts with", fill_in: "Autauga")

    click_on("Create Broadcast")

    expect(page).to have_content("Broadcast was successfully created.")

    within("#beneficiary_filter_iso_country_code") do
      expect(page).to have_field(with: "Country")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "United States of America")
    end
    within("#beneficiary_filter_iso_region_code") do
      expect(page).to have_field(with: "ISO region code")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "US-AL")
    end
    within("#beneficiary_filter_administrative_division_level_2_code") do
      expect(page).to have_field(with: "Administrative division level 2 code")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "001")
    end
    within("#beneficiary_filter_administrative_division_level_2_name") do
      expect(page).to have_field(with: "Administrative division level 2 name")
      expect(page).to have_field(with: "Starts with")
      expect(page).to have_field(with: "Autauga")
    end
  end

  it "handles whitelisted beneficiary filters" do
    account = create(
      :account,
      iso_country_code: "KH",
      dashboard_broadcast_beneficiary_filter_whitelist: [
        "administrative_division_level_3_code",
        "gender"
      ]
    )
    user = create(:user, account:)

    account_sign_in(user)
    visit new_dashboard_broadcast_path

    expect(page).to have_field(with: "Target areas")
    expect(page).to have_field(with: "Gender")
    expect(page).to have_no_field(with: "Phone number")
  end

  it "show a broadcast" do
    account = create(:account, iso_country_code: "US")
    user = create(:user, account:)
    broadcast = create(
      :broadcast,
      account:,
      beneficiary_filter: {
        gender: { eq: "M" }
      },
      target_areas: {
        geocode: [
          { iso_region_code: "US-AL" },
          { iso_region_code: "US-NY", administrative_division_level_2_code: "0201" }
        ]
      }
    )

    account_sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    expect(page).to have_content("US-AL")
    expect(page).to have_field(with: "Male")
  end

  it "show a broadcast with a tree", :js do
    account = create(:account, iso_country_code: "KH")
    user = create(:user, account:)
    broadcast = create(:broadcast, account:)
    create(
      :geocode_target_area,
      path: [ "KH-1", "0102", "010201" ],
      broadcast:
    )
    create(
      :geocode_target_area,
      path: [ "KH-2", "0201" ],
      broadcast:
    )

    account_sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    within("#target_areas") do
      expect(page).to have_content("Banteay Meanchey")
      expect(page).to have_content("Mongkol Borey")
      expect(page).to have_content("Banteay Neang")
      expect(page).to have_no_content("Bat Trang")
      expect(page).to have_no_content("Phnum Srok")
      expect(page).to have_content("Battambang")
      expect(page).to have_content("Banan")
      expect(page).to have_content("Kantueu Muoy")
      expect(page).to have_content("Kantueu Pir")
      expect(page).to have_no_content("Thma Koul")
      expect(page).to have_no_content("Phnom Penh")
    end
  end

  it "update a broadcast", :js do
    account = create(:account, iso_country_code: "KH")
    user = create(:user, account:)
    create_beneficiary_group(name: "My other group", account:)
    broadcast = create(
      :broadcast,
      :with_attached_audio,
      audio_filename: "test.mp3",
      account: user.account,
      beneficiary_groups: [ create_beneficiary_group(name: "My group", account:) ],
      beneficiary_filter: {
        phone_number: { in: [ "855715100850",  "855715100851" ] },
        disability_status: { eq: 'none' },
        "address.administrative_division_level_3_code": { in: [ "120101" ] }
      }
    )

    account_sign_in(user)
    visit edit_dashboard_broadcast_path(broadcast)

    expect(page).to have_link("test.mp3")
    expect(page).to have_select("Channel", disabled: true)

    fill_in("Name", with: "My updated broadcast")
    select_list("My other group", from: "Beneficiary groups")
    select_filter("Gender", operator: "Equals", select: "Male")
    select_filter("Disability status", operator: "Equals", select: "Disabled")
    select_filter("ISO language code", operator: "Equals", fill_in: "khm")
    select_tree("Banteay Meanchey", "Mongkol Borey", "Banteay Neang")

    click_on "Update Broadcast"

    expect(page).to have_content("Broadcast was successfully updated.")
    expect(page).to have_content("My updated broadcast")
    expect(page).to have_content("My group")
    expect(page).to have_content("My other group")
    expect(page).to have_content(user.name)
    within("#beneficiary_filter_gender") do
      expect(page).to have_field(with: "Gender")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "Male")
    end
    within("#beneficiary_filter_disability_status") do
      expect(page).to have_field(with: "Disability status")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "Disabled")
    end
    within("#beneficiary_filter_iso_language_code") do
      expect(page).to have_field(with: "ISO language code")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "khm")
    end
    within("#beneficiary_filter_phone_number") do
      expect(page).to have_field(with: "Phone number")
      expect(page).to have_field(with: "In")
      expect(page).to have_select(selected: [ "855715100850",  "855715100851" ])
    end
    within("#beneficiary_filter_administrative_division_level_3_code") do
      expect(page).to have_content("Banteay Meanchey")
      expect(page).to have_content("Mongkol Borey")
      expect(page).to have_content("Banteay Neang")
      expect(page).to have_content("Phnom Penh")
      expect(page).to have_content("Chamkar Mon")
      expect(page).to have_content("Tonle Basak")
    end
  end

  it "update a broadcast created via the API", :js do
    account = create(
      :account,
      iso_country_code: "KH",
      dashboard_broadcast_beneficiary_filter_whitelist: [
        "administrative_division_level_3_code",
        "gender"
      ]
    )
    broadcast = create(
      :broadcast,
      :pending,
      account:,
      created_via: :api,
      beneficiary_filter: {
        date_of_birth: { between: [ "2000-01-01", "2010-01-01" ] },
        "address.administrative_division_level_2_name": { eq: "Chamkar Mon" },
        "address.administrative_division_level_3_code": { in: [ "120101" ] }
      }
    )
    user = create(:user, account:)

    account_sign_in(user)
    visit edit_dashboard_broadcast_path(broadcast)

    expect(page).to have_no_content("Date of birth")
    expect(page).to have_no_content("District name")

    select_filter("Gender", operator: "Equals", select: "Female")

    click_on("Update Broadcast")

    within("#beneficiary_filter_gender") do
      expect(page).to have_field(with: "Gender")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "Female")
    end
    within("#beneficiary_filter_date_of_birth") do
      expect(page).to have_field(with: "Date of birth")
      expect(page).to have_field(with: "Between")
      expect(page).to have_field(with: "2000-01-01")
      expect(page).to have_field(with: "2010-01-01")
    end
    within("#beneficiary_filter_administrative_division_level_2_name") do
      expect(page).to have_field(with: "District name")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "Chamkar Mon")
    end
    within("#beneficiary_filter_administrative_division_level_3_code") do
      expect(page).to have_content("Phnom Penh")
      expect(page).to have_content("Chamkar Mon")
      expect(page).to have_content("Tonle Basak")
    end
  end

  it "delete a broadcast" do
    user = create(:user)
    broadcast = create(:broadcast, account: user.account)

    account_sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    click_on "Delete"

    expect(page).to have_text("Broadcast was successfully destroyed.")
    expect(page).to have_current_path(dashboard_broadcasts_path)
  end

  it "start a broadcast" do
    account = create(:account, :configured_for_broadcasts)
    user = create(:user, account:)
    create(:beneficiary, account:, gender: "M")

    broadcast = create(
      :broadcast,
      :pending,
      :with_attached_audio,
      account: account,
      beneficiary_filter: {
        gender: { eq: "M" }
      }
    )

    account_sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    perform_enqueued_jobs do
      click_on "Start"
    end

    expect(page).to have_text("Broadcast was successfully updated.")
    expect(page).to have_text("Running")
    expect(page).to have_content(user.name)
  end

  it "stop a broadcast" do
    account = create(:account)
    user = create(:user, account:)
    broadcast = create(:broadcast, :running, account:)

    account_sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    click_on "Stop"

    expect(page).to have_text("Broadcast was successfully updated.")
    expect(page).to have_text("Stopped")
    expect(page).to have_content(user.name)
  end

  it "fail to start a broadcast" do
    account = create(:account, :configured_for_broadcasts)
    user = create(:user, account:)
    create(:beneficiary, account:, gender: "F")

    broadcast = create(
      :broadcast,
      :pending,
      :with_attached_audio,
      account: account,
      beneficiary_filter: {
        gender: { eq: "M" }
      }
    )

    account_sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    perform_enqueued_jobs do
      click_on "Start"
    end

    expect(page).to have_text("Errored")
    expect(page).to have_text("No beneficiaries match the filters")
  end

  def select_tree(*values)
    within("#broadcast_beneficiary_filter_administrative_division_level_3_code") do
      values.each do |value|
        title = find("a", text: value)
        if value == values.last
          title.find(:xpath, "preceding-sibling::input[@type='checkbox'][1]").click
        else
          title.find(:xpath, 'preceding-sibling::a[1]').click
        end
      end
    end
  end

  def create_beneficiary_group(attributes)
    beneficiary_group = create(:beneficiary_group, **attributes)
    create(
      :beneficiary_group_membership,
      beneficiary_group: beneficiary_group,
      beneficiary: create(:beneficiary, account: beneficiary_group.account)
    )
    beneficiary_group
  end
end
