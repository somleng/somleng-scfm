class SensorEvent < ApplicationRecord
  PAYLOAD_SENSOR_ID_KEY = "sensor_id".freeze

  include JsonQueryHelpers
  include KeyValueFieldsFor

  belongs_to :sensor
  belongs_to :sensor_rule, optional: true

  attr_accessor :account

  before_validation :attach_to_sensor

  accepts_nested_key_value_fields_for :payload

  private

  def attach_to_sensor
    return unless account.present?
    self.sensor ||= account.sensors.find_by(external_id: payload_sensor_id)
  end

  def payload_sensor_id
    payload[PAYLOAD_SENSOR_ID_KEY]
  end
end
