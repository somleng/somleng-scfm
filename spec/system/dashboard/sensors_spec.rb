require "rails_helper"

RSpec.describe "Sensors", :aggregate_failures do
  let(:admin) { create(:admin) }

  it "can list sensors" do
    sensor = create(
      :sensor,
      account: admin.account,
      commune_ids: ["040101"]
    )

    other_sensor = create(:sensor)

    sign_in(admin)
    visit dashboard_sensors_path

    within("#page_actions") do
      expect(page).to have_link_to_action(
        :new, key: :sensors, href: new_dashboard_sensor_path
      )
    end

    within("#resources") do
      expect(page).to have_content_tag_for(sensor)
      expect(page).not_to have_content_tag_for(other_sensor)
      expect(page).to have_content("#")
      expect(page).to have_content("Province")
      expect(page).to have_link(
        sensor.id,
        href: dashboard_sensor_path(sensor)
      )
      expect(page).to have_content("Kampong Chhnang")
      expect(page).to have_content("កំពង់ឆ្នាំង")
    end
  end

  it "can create a sensor", :js do
    sign_in(admin)
    visit new_dashboard_sensor_path

    expect(page).to have_link_to_action(:cancel)

    fill_in("External id", with: "sensor005")
    select_selectize("#province", "Battambang")
    select_selectize("#communes", "Kantueu Pir")

    fill_in_key_value_for(
      :metadata,
      with: { key: "height_above_sea_level", value: "100" },
      index: 0
    )

    add_key_value_for(:metadata)

    fill_in_key_value_for(
      :metadata,
      with: { key: "latitude", value: "11.5627465" },
      index: 1
    )

    add_key_value_for(:metadata)

    fill_in_key_value_for(
      :metadata,
      with: { key: "longitude", value: "104.9104493" },
      index: 2
    )

    click_action_button(:create, key: :submit, namespace: :helpers, model: "Sensor")

    expect(page).to have_text("Sensor was successfully created.")
    sensor = admin.account.reload.sensors.last!
    expect(sensor).to be_persisted
    expect(sensor.external_id).to eq("sensor005")
    expect(sensor.metadata.fetch("height_above_sea_level")).to eq("100")
    expect(sensor.metadata.fetch("latitude")).to eq("11.5627465")
    expect(sensor.metadata.fetch("longitude")).to eq("104.9104493")
    expect(sensor.commune_ids).to match_array(["020102"])
  end

  it "can show a sensor" do
    sensor = create(
      :sensor,
      account: admin.account,
      metadata: {
        "latitude": "11.5633885",
        "longitude": "104.915919"
      }
    )

    sign_in(admin)
    visit dashboard_sensor_path(sensor)

    within("#related_links") do
      expect(page).to have_link_to_action(
        :index,
        key: :sensor_rules,
        href: dashboard_sensor_sensor_rules_path(sensor)
      )

      expect(page).to have_link_to_action(
        :index,
        key: :sensor_events,
        href: dashboard_sensor_sensor_events_path(sensor)
      )
    end

    within("#sensor") do
      expect(page).to have_content(sensor.id)
      expect(page).to have_content("Province")
      expect(page).to have_content("Alert communes")
      expect(page).to have_content("latitude")
      expect(page).to have_content("longitude")
      expect(page).to have_content("Created at")
    end
  end

  it "can update sensor", :js do
    sensor = create(
      :sensor,
      account: admin.account,
      commune_ids: ["010201"],
      metadata: {
        "foo" => "bar"
      }
    )

    sign_in(admin)
    visit edit_dashboard_sensor_path(sensor)

    expect(page).to have_content("Banteay Neang")
    expect(page).to have_link_to_action(:cancel)

    fill_in("External id", with: "sensor005")
    select_selectize("#province", "Battambang")
    select_selectize("#communes", "Kantueu Pir")
    remove_key_value_for(:metadata, index: 0)
    add_key_value_for(:metadata)
    fill_in_key_value_for(
      :metadata,
      with: { key: "height_above_sea_level", value: "100" },
      index: 0
    )
    click_action_button(:update, key: :submit, namespace: :helpers, model: "Sensor")

    expect(page).to have_text("Sensor was successfully updated.")
    sensor.reload
    expect(sensor.external_id).to eq("sensor005")
    expect(sensor.commune_ids).to match_array(["020102"])
    expect(sensor.metadata.fetch("height_above_sea_level")).to eq("100")
    expect(sensor.metadata).not_to have_key("foo")
  end

  it "can delete sensor" do
    sensor = create(:sensor, account: admin.account)

    sign_in(admin)
    visit dashboard_sensor_path(sensor)

    click_action_button(:delete, type: :link)

    expect(current_path).to eq(dashboard_sensors_path)
    expect(page).to have_text("Sensor was successfully destroyed.")
  end
end
