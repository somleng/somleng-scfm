require "rails_helper"

RSpec.describe "Sensors", :aggregate_failures do
  let(:admin) { create(:admin) }

  it "can list sensors" do
    sensor = create(:sensor, account: admin.account)
    other_sensor = create(:sensor)

    sign_in(admin)
    visit dashboard_sensors_path

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :new, key: :sensors, href: new_dashboard_sensor_path
      )
      expect(page).to have_link_to_action(:index, key: :sensors)
    end

    within("#resources") do
      expect(page).to have_content_tag_for(sensor)
      expect(page).not_to have_content_tag_for(other_sensor)
      expect(page).to have_content("#")
      expect(page).to have_link(
        sensor.id,
        href: dashboard_sensor_path(sensor)
      )
      expect(page).to have_content("Kampong Chhnang")
      expect(page).to have_content("កំពង់ឆ្នាំង")
      expect(page).to have_content("Rules")
    end
  end

  it "can create a sensor", :js do
    sign_in(admin)
    visit new_dashboard_sensor_path

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.sensors.new"),
        href: new_dashboard_sensor_path
      )
    end

    expect(page).to have_link_to_action(:cancel)

    fill_in_sensor_info(province: "Battambang", level: 600)
    click_action_button(:create, key: :sensors)

    expect(page).to have_text("Sensor was successfully created.")
    expect(page).to have_content("Battambang")
    expect(page).to have_content("600")
  end

  it "can show sensor details" do
    sensor = create(:sensor, account: admin.account)
    sensor_rule = create(:sensor_rule, sensor: sensor, level: 1000)

    sign_in(admin)
    visit dashboard_sensor_path(sensor)

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :edit,
        href: edit_dashboard_sensor_path(sensor)
      )
    end

    within("#sensor") do
      expect(page).to have_content(sensor.id)
      expect(page).to have_content("Province")
      expect(page).to have_content("Created at")
      expect(page).to have_content("1000")
    end
  end

  it "can update sensor", :js do
    sensor = create(:sensor, :with_rules, account: admin.account)

    sign_in(admin)
    visit edit_dashboard_sensor_path(sensor)

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.sensors.edit"),
        href: edit_dashboard_sensor_path(sensor)
      )
    end

    expect(page).to have_link_to_action(:cancel)

    fill_in_sensor_info(province: "Battambang", level: 1000)
    click_action_button(:update, key: :sensors)

    expect(page).to have_text("Sensor was successfully updated.")
    expect(page).to have_content("Battambang")
    expect(page).to have_content("1000")
  end

  it "can delete sensor" do
    sensor = create(:sensor, account: admin.account)

    sign_in(admin)
    visit dashboard_sensor_path(sensor)

    click_action_button(:delete, type: :link)

    expect(current_path).to eq(dashboard_sensors_path)
    expect(page).to have_text("Sensor was successfully destroyed.")
  end

  def fill_in_sensor_info(options = {})
    click_on("Remove")
    select_selectize("#province", options[:province])
    click_on("Add")
    fill_in("Level", with: options[:level])
    file_path = Rails.root + file_fixture("test.mp3")
    attach_file "Voice file", file_path
  end
end
