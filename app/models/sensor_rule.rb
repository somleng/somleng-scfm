class SensorRule < ApplicationRecord
  AUDIO_CONTENT_TYPES = %w[audio/mpeg audio/mp3 audio/wav].freeze

  store_accessor :metadata, :level

  belongs_to :sensor
  has_one_attached :voice

  validates :level, presence: true, numericality: { only_integer: true }

  validates :voice, file: {
    presence: true, type: AUDIO_CONTENT_TYPES,
    size: 10.megabytes
  }
end
