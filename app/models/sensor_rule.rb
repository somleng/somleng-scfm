class SensorRule < ApplicationRecord
  include MetadataHelpers

  belongs_to :sensor

  has_many :sensor_events,
           dependent: :restrict_with_error

  has_one_attached :alert_file

  validates :level,
            presence: true,
            numericality: { only_integer: true }

  validate :validate_presence_of_alert_file

  validates :alert_file,
            file_size: {
              less_than_or_equal_to: 10.megabytes
            },
            file_content_type: {
              allow: Callout::AUDIO_CONTENT_TYPES
            },
            if: ->(sensor_rule) { sensor_rule.alert_file.attached? }

  delegate :account, to: :sensor, allow_nil: true

  def runnable?
    return true if last_run_at.blank?
    return true if account.sensor_rule_run_interval_in_hours.blank?

    (last_run_at + account.sensor_rule_run_interval_in_hours.hours) <= Time.current
  end

  private

  def self.find_by_highest_level(value)
    where(arel_table[:level].lteq(value)).order(level: :desc).first
  end

  def validate_presence_of_alert_file
    return if alert_file.attached?
    errors.add(:alert_file, :blank)
  end
end
