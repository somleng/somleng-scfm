require "rails_helper"

RSpec.describe "Sensor Events" do
  let(:access_token) { create_access_token }
  let(:account) { access_token.resource_owner }

  it "can list all sensor events" do
    filtered_sensor_event = create_sensor_event(
      account: account,
      payload: {
        "foo" => "bar",
        "voltage" => "5"
      }
    )
    create_sensor_event(account: account)
    create(:sensor_event)

    get(
      api_sensor_events_path(
        q: {
          "payload" => {
            "voltage" => "5"
          }
        }
      ),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(filtered_sensor_event.id)
  end

  it "can list all sensor events for a sensor" do
    sensor = create(:sensor, account: account)
    sensor_event = create_sensor_event(account: account, sensor: sensor)
    _other_sensor_event = create_sensor_event(account: account)

    get(
      api_sensor_sensor_events_path(sensor),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(sensor_event.id)
  end

  it "can list all sensor events for a sensor rule" do
    sensor = create(:sensor, account: account)
    sensor_rule = create(:sensor_rule, sensor: sensor)
    sensor_event = create_sensor_event(account: account, sensor: sensor, sensor_rule: sensor_rule)
    _other_sensor_event = create_sensor_event(account: account, sensor: sensor)

    get(
      api_sensor_rule_sensor_events_path(sensor_rule),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(sensor_event.id)
  end

  it "can fetch a sensor event" do
    sensor_event = create_sensor_event(account: account)

    get(
      api_sensor_event_path(sensor_event),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(account.sensor_events.find(parsed_body.fetch("id"))).to eq(sensor_event)
  end

  it "can create a sensor event" do
    sensor = create(:sensor, account: account)
    request_body = {
      payload: {
        "voltage" => "5",
        "sensor_id" => sensor.external_id
      }
    }

    post(
      api_sensor_events_path,
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    parsed_body = JSON.parse(response.body)
    sensor_event = sensor.sensor_events.find(parsed_body.fetch("id"))
    expect(sensor_event.payload).to eq(request_body.fetch(:payload))
    expect(sensor_event.sensor).to eq(sensor)
  end

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[sensor_events_read sensor_events_write],
      **options
    )
  end
end
