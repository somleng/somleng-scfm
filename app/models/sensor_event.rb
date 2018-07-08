class SensorEvent < ApplicationRecord
  PAYLOAD_SENSOR_ID_KEY = "sensor_id".freeze
  PAYLOAD_SENSOR_LEVEL_KEY = "level".freeze

  include JsonQueryHelpers
  include KeyValueFieldsFor

  belongs_to :sensor
  belongs_to :sensor_rule, optional: true
  has_one :callout

  attr_accessor :account

  before_validation :attach_to_sensor
  before_create :attach_to_sensor_rule

  accepts_nested_key_value_fields_for :payload

  delegate :runnable?, to: :sensor_rule, allow_nil: true, prefix: true

  private

  def attach_to_sensor
    return unless account.present?
    self.sensor ||= account.sensors.find_by(external_id: payload_sensor_id)
  end

  def attach_to_sensor_rule
    self.sensor_rule ||= sensor.sensor_rules.find_by_highest_level(payload_sensor_level)
  end

  def payload_sensor_id
    payload[PAYLOAD_SENSOR_ID_KEY]
  end

  def payload_sensor_level
    payload[PAYLOAD_SENSOR_LEVEL_KEY]
  end
end
