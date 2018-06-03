class SensorRule < ApplicationRecord
  AUDIO_CONTENT_TYPES = %w[audio/mpeg audio/mp3 audio/wav].freeze
  include MetadataHelpers

  belongs_to :sensor

  has_many :sensor_events,
           dependent: :restrict_with_error

  has_one_attached :alert_file

  store_accessor :metadata, :level

  validates :level,
            presence: true,
            numericality: { only_integer: true }

  validates :alert_file,
            file: {
              presence: true,
              type: AUDIO_CONTENT_TYPES,
              size: 10.megabytes
            }
end
