require "rails_helper"

RSpec.describe "Sensors", :aggregate_failures do
  it "can list sensor events" do
    user = create(:admin)
    sensor_event = create_sensor_event(account: user.account)
    other_sensor_event = create(:sensor_event)

    sign_in(user)
    visit(dashboard_sensor_events_path)

    within("#resources") do
      expect(page).to have_content_tag_for(sensor_event)
      expect(page).not_to have_content_tag_for(other_sensor_event)
      expect(page).to have_content("#")
      expect(page).to have_link(
        sensor_event.id,
        href: dashboard_sensor_event_path(sensor_event)
      )
    end
  end

  it "can list sensor events for a sensor" do
    user = create(:admin)
    sensor = create(:sensor, account: user.account)
    sensor_event = create_sensor_event(account: user.account, sensor: sensor)
    other_sensor_event = create_sensor_event(account: user.account)

    sign_in(user)
    visit(dashboard_sensor_sensor_events_path(sensor))

    within("#resources") do
      expect(page).to have_content_tag_for(sensor_event)
      expect(page).not_to have_content_tag_for(other_sensor_event)
    end
  end

  it "can list sensor events for a sensor rule" do
    user = create(:admin)
    sensor = create(:sensor, account: user.account)
    sensor_rule = create(:sensor_rule, sensor: sensor)
    sensor_event = create_sensor_event(
      account: user.account, sensor: sensor, sensor_rule: sensor_rule
    )
    other_sensor_event = create_sensor_event(account: user.account, sensor: sensor)

    sign_in(user)
    visit(dashboard_sensor_rule_sensor_events_path(sensor_rule))

    within("#resources") do
      expect(page).to have_content_tag_for(sensor_event)
      expect(page).not_to have_content_tag_for(other_sensor_event)
    end
  end

  it "can show a sensor event" do
    user = create(:admin)
    sensor = create(:sensor, account: user.account)
    sensor_rule = create_sensor_rule(account: user.account, sensor: sensor)
    sensor_event = create_sensor_event(
      account: user.account, sensor: sensor, sensor_rule: sensor_rule
    )

    sign_in(user)
    visit(dashboard_sensor_event_path(sensor_event))

    within("#resource") do
      expect(page).to have_content(sensor_event.id)

      expect(page).to have_link(
        sensor_event.sensor_id,
        href: dashboard_sensor_path(sensor_event.sensor_id)
      )

      expect(page).to have_link(
        sensor_event.sensor_rule_id,
        href: dashboard_sensor_rule_path(sensor_event.sensor_rule_id)
      )

      expect(page).to have_content("#")
      expect(page).to have_content("Sensor")
      expect(page).to have_content("Created at")
      expect(page).to have_content("Payload")
    end
  end
end
