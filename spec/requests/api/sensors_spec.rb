require "rails_helper"

RSpec.describe "Sensors" do
  let(:access_token) { create(:access_token) }
  let(:account) { access_token.resource_owner }

  it "can list sensors" do
    filtered_sensor = create(
      :sensor,
      metadata: {
        "commune_ids" => %w[120101 120102],
        "foo" => "bar"
      },
      account: account
    )
    create(:sensor, account: account)
    create(:sensor)

    get(
      api_sensors_path(
        q: {
          "metadata" => {
            "foo" => "bar"
          }
        }
      ),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(filtered_sensor.id)
  end

  it "can create a sensor" do
    request_body = {
      external_id: generate(:sensor_external_id),
      metadata: {
        "commune_ids" => %w[120101 120102]
      }
    }

    post(
      api_sensors_path,
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    parsed_response = JSON.parse(response.body)
    expect(parsed_response.fetch("metadata")).to eq(request_body.fetch(:metadata))
    expect(parsed_response.fetch("external_id")).to eq(request_body.fetch(:external_id))
    expect(account.sensors.find(parsed_response.fetch("id"))).to be_a(Sensor)
  end

  it "can fetch a sensor" do
    sensor = create(:sensor, account: account)

    get(
      api_sensor_path(sensor),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    expect(response.body).to eq(sensor.to_json)
  end

  it "can update a sensor" do
    sensor = create(
      :sensor,
      account: account,
      metadata: {
        "commune_ids" => ["120101"],
        "foo" => "bar"
      }
    )

    request_body = {
      metadata: {
        "commune_ids" => %w[120101 120102]
      },
      metadata_merge_mode: "replace"
    }

    patch(
      api_sensor_path(sensor),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(sensor.reload.metadata).to eq(request_body.fetch(:metadata))
  end

  it "can delete a sensor" do
    sensor = create(:sensor, account: account)

    delete(
      api_sensor_path(sensor),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(Sensor.find_by_id(sensor.id)).to eq(nil)
  end

  it "cannot delete a sensor with rules" do
    sensor = create(:sensor, account: account)
    _sensor_rule = create(:sensor_rule, sensor: sensor)

    delete(
      api_sensor_path(sensor),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  it "cannot delete a sensor with events" do
    sensor = create(:sensor, account: account)
    _sensor_event = create(:sensor_event, sensor: sensor)

    delete(
      api_sensor_path(sensor),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end
end
