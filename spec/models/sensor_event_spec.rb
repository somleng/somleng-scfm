require "rails_helper"

RSpec.describe SensorEvent do
  describe "associations" do
    it { is_expected.to belong_to(:sensor) }
    it { is_expected.to belong_to(:sensor_rule).optional }
  end

  describe "validations" do
    it "can attach the event to a sensor" do
      account = create(:account)
      sensor = create(:sensor, account: account)
      sensor_event = described_class.new(
        payload: {
          "sensor_id" => sensor.external_id
        },
        authorized_account: account
      )

      expect(sensor_event).to be_valid
      expect(sensor_event.sensor).to eq(sensor)
    end
  end
end
