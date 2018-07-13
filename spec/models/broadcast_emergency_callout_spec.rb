require "rails_helper"

RSpec.describe BroadcastEmergencyCallout do
  it "creates a callout for the sensor event" do
    sensor_event = create_sensor_event

    broadcast = broadcast_emergency_callout(sensor_event)

    expect(broadcast.callout).to be_persisted
    expect(sensor_event.callout).to eq(broadcast.callout)
  end

  it "sets the callout to be running" do
    sensor_event = create_sensor_event

    broadcast = broadcast_emergency_callout(sensor_event)

    expect(broadcast.callout).to be_running
  end

  it "creates callout participations that matches with sensor's communes" do
    sensor = create(:sensor, commune_ids: %w[120101 120101])
    participation1 = create(:contact, commune_id: "120101", account: sensor.account)
    participation2 = create(:contact, commune_id: "120101", account: sensor.account)
    _not_paticipation = create(:contact, commune_id: "110101", account: sensor.account)
    sensor_event = create_sensor_event(sensor: sensor)

    perform_enqueued_jobs(only: RunBatchOperationJob) do
      broadcast = broadcast_emergency_callout(sensor_event)

      expect(broadcast.callout.contacts).to match_array(
        [participation1, participation2]
      )
    end
  end

  def broadcast_emergency_callout(sensor_event)
    broadcast = described_class.new(sensor_event)
    broadcast.call
    broadcast
  end

  def create_sensor_event(sensor: nil)
    sensor ||= create(:sensor)
    sensor_rule = create(:sensor_rule, sensor: sensor)
    create(:sensor_event, sensor: sensor, sensor_rule: sensor_rule)
  end
end
