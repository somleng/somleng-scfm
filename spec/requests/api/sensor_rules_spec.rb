require "rails_helper"

RSpec.describe "Sensor Rules" do
  let(:access_token) { create_access_token }
  let(:account) { access_token.resource_owner }

  it "can list sensor rules" do
    filtered_sensor_rule = create_sensor_rule(
      account: account,
      metadata: {
        "foo" => "bar",
        "level" => 500
      }
    )
    create_sensor_rule(account: account)
    create(:sensor_rule)

    get(
      api_sensor_rules_path(
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
    expect(parsed_body.first.fetch("id")).to eq(filtered_sensor_rule.id)
  end

  it "can list sensor rules for a sensor" do
    sensor_rule = create_sensor_rule(account: account)
    other_sensor = create(:sensor, account: account)
    _other_sensor_rule = create_sensor_rule(sensor: other_sensor, account: account)

    get(
      api_sensor_sensor_rules_path(sensor_rule.sensor),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(sensor_rule.id)
  end

  it "can create a sensor rule" do
    sensor = create(:sensor, account: account)
    request_body = {
      alert_file: fixture_file_upload("files/test.mp3", "audio/mp3"),
      level: 100,
      metadata: {
        "description" => "description"
      }
    }

    post(
      api_sensor_sensor_rules_path(sensor),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    parsed_body = JSON.parse(response.body)
    expect(sensor.reload.sensor_rules.size).to eq(1)
    sensor_rule = sensor.sensor_rules.find(parsed_body.fetch("id"))
    expect(sensor_rule.level).to eq(request_body.fetch(:level).to_s)
    expect(sensor_rule.alert_file).to be_attached
    expect(sensor_rule.metadata).to include(request_body.fetch(:metadata))
  end

  it "can fetch a sensor rule" do
    sensor_rule = create_sensor_rule(account: account)

    get(
      api_sensor_rule_path(sensor_rule),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(account.sensor_rules.find(parsed_body.fetch("id"))).to eq(sensor_rule)
  end

  it "can update a sensor rule" do
    original_metadata = {
      "foo" => "bar"
    }

    sensor_rule = create_sensor_rule(
      account: account,
      level: 200,
      metadata: original_metadata
    )

    request_body = {
      level: 100,
      metadata: {
        "description" => "description"
      }
    }

    patch(
      api_sensor_rule_path(sensor_rule),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    sensor_rule.reload
    expect(sensor_rule.level).to eq(request_body.fetch(:level).to_s)
    expect(sensor_rule.metadata).to include(request_body.fetch(:metadata))
    expect(sensor_rule.metadata).to include(original_metadata)
  end

  it "can delete a sensor rule" do
    sensor_rule = create_sensor_rule(account: account)

    delete(
      api_sensor_rule_path(sensor_rule),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(SensorRule.find_by_id(sensor_rule.id)).to eq(nil)
  end

  it "cannot delete a sensor rule with sensor events" do
    sensor_rule = create_sensor_rule(account: account)
    _sensor_event = create(:sensor_event, sensor_rule: sensor_rule)

    delete(
      api_sensor_rule_path(sensor_rule),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[sensor_rules_read sensor_rules_write],
      **options
    )
  end
end
