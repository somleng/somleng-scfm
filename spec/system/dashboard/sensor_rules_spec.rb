require "rails_helper"

RSpec.describe "Sensors", :aggregate_failures do
  let(:admin)  { create(:admin) }
  let(:sensor) { create(:sensor, account: admin.account) }

  it "can list sensors" do
    rule = create(:sensor_rule, level: 1000, sensor: sensor)
    other_rule = create(:sensor)

    sign_in(admin)
    visit dashboard_sensor_sensor_rules_path(sensor)

    within("#button_toolbar") do
      expect(page).to have_link_to_action(:index, key: :sensor_rules)
      expect(page).to have_link_to_action(:back)
      expect(page).to have_link_to_action(
        :new, key: :sensor_rules, href: new_dashboard_sensor_sensor_rule_path(sensor)
      )
    end

    within("#resources") do
      expect(page).to have_content_tag_for(rule)
      expect(page).not_to have_content_tag_for(other_rule)
      expect(page).to have_content("#")
      expect(page).to have_link(
        rule.id,
        href: dashboard_sensor_rule_path(rule)
      )
      expect(page).to have_content("1000")
    end
  end

  it "can create a sensor rule" do
    sign_in(admin)
    visit new_dashboard_sensor_sensor_rule_path(sensor)

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.sensor_rules.new"),
        href: new_dashboard_sensor_sensor_rule_path(sensor)
      )
    end

    expect(page).to have_link_to_action(:cancel)

    fill_in_sensor_rule_info(level: 1000)
    click_action_button(:create, key: :submit, namespace: :helpers, model: "Sensor rule")

    expect(page).to have_text("Sensor rule was successfully created.")
    sensor_rule = admin.account.sensor_rules.last!
    expect(current_path).to eq(dashboard_sensor_rule_path(sensor_rule))
    expect(page).to have_content("1000")
  end

  it "can show a sensor rule" do
    rule = create(:sensor_rule, sensor: sensor, level: 1000)

    sign_in(admin)
    visit dashboard_sensor_rule_path(rule)

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :edit,
        href: edit_dashboard_sensor_rule_path(rule)
      )

      expect(page).to have_link_to_action(
        :index,
        key: :sensor_events,
        href: dashboard_sensor_rule_sensor_events_path(rule)
      )
    end

    within("#sensor") do
      expect(page).to have_content(sensor.id)
      expect(page).to have_content("Level")
      expect(page).to have_content("1000")
      expect(page).to have_content("Alert file")
      expect(page).to have_content("Created at")
    end
  end

  it "can update sensor rule", :js do
    rule = create(:sensor_rule, sensor: sensor, level: 1000)

    sign_in(admin)
    visit edit_dashboard_sensor_rule_path(rule)

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.sensor_rules.edit"),
        href: edit_dashboard_sensor_rule_path(rule)
      )
    end

    expect(page).to have_link_to_action(:cancel)

    fill_in_sensor_rule_info(level: 1500)
    click_action_button(:update, key: :submit, namespace: :helpers, model: "Sensor rule")

    expect(page).to have_content("Sensor rule was successfully updated.")
    expect(current_path).to eq(dashboard_sensor_rule_path(rule))
    expect(page).to have_content("1500")
  end

  it "can delete sensor rule" do
    rule = create(:sensor_rule, sensor: sensor, level: 1000)

    sign_in(admin)
    visit dashboard_sensor_rule_path(rule)

    click_action_button(:delete, type: :link)

    expect(page).to have_content("Sensor rule was successfully destroyed.")
    expect(current_path).to eq(dashboard_sensor_sensor_rules_path(sensor))
  end

  def fill_in_sensor_rule_info(option = {})
    fill_in("Level", with: option[:level])
    file_path = Rails.root + file_fixture("test.mp3")
    attach_file "Alert file", file_path
  end
end
