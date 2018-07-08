require "rails_helper"

RSpec.describe SensorEvent do
  describe "validations" do
    it "can attach the event to a sensor" do
      sensor = create(:sensor)
      sensor_event = build_sensor_event(sensor)

      expect(sensor_event).to be_valid
      expect(sensor_event.sensor).to eq(sensor)
    end

    it "doesn't attach the event to a sensor rule if there is no matching rules" do
      sensor = create(:sensor)
      sensor_rule = create(:sensor_rule, sensor: sensor, level: 100)
      sensor_event = build_sensor_event(sensor, level: 50)

      expect(sensor_event.save).to eq(true)
      expect(sensor_event.sensor_rule).to be_blank
    end

    it "attaches the event to a sensor rule" do
      sensor = create(:sensor)
      sensor_rule = create(:sensor_rule, sensor: sensor, level: 100)
      sensor_event = build_sensor_event(sensor, level: 150)

      expect(sensor_event.save).to eq(true)
      expect(sensor_event.sensor_rule).to eq(sensor_rule)
    end
  end

  def build_sensor_event(sensor, level: 100)
    described_class.new(
      payload: {
        "sensor_id" => sensor.external_id,
        "level" => level
      },
      account: sensor.account
    )
  end
end
