class Callout < ApplicationRecord
  include MetadataHelpers
  include HasCallFlowLogic

  belongs_to :account

  has_many :callout_participations, dependent: :restrict_with_error

  has_many :batch_operations,
           class_name: "BatchOperation::Base",
           dependent: :restrict_with_error

  has_many :phone_calls,
           through: :callout_participations

  has_many :remote_phone_call_events,
           through: :phone_calls

  has_many :contacts,
           through: :callout_participations

  store_accessor :metadata, :province_id, :commune_ids

  has_one_attached :voice

  alias_attribute :calls, :phone_calls

  validates :status, presence: true
  validates :province_id, presence: true, on: :dashboard
  validates :commune_ids, array: true, on: :dashboard

  validate  :validate_voice, on: :dashboard
  validate  :validate_commune_ids, on: :dashboard

  include AASM

  aasm column: :status, whiny_transitions: false do
    state :initialized, initial: true
    state :running
    state :paused
    state :stopped

    event :start do
      transitions(
        from: :initialized,
        to: :running
      )
    end

    event :pause do
      transitions(
        from: :running,
        to: :paused
      )
    end

    event :resume do
      transitions(
        from: %i[paused stopped],
        to: :running
      )
    end

    event :stop do
      transitions(
        from: %i[running paused],
        to: :stopped
      )
    end
  end

  def title
    metadata["title"] || "Calout #{id}"
  end

  private

  def validate_commune_ids
    if commune_ids.blank? || commune_ids.reject!(&:empty?).blank?
      errors.add(:commune_ids, :blank)
    else
      commune_ids.each do |commune_id|
        next if commune_id =~ /^#{province_id}/
        errors.add(:commune_ids)
      end
    end
  end

  # https://github.com/rails/rails/issues/31656
  def validate_voice
    if voice.attached?
      errors.add(:voice, :audio_type) unless voice.blob.audio?
      errors.add(:voice, :audio_size) if voice.blob.byte_size.bytes > 5.megabytes
    else
      errors.add(:voice, :blank)
    end
    voice.purge_later if errors[:voice].present?
  end
end
