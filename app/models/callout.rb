class Callout < ApplicationRecord
  include MetadataHelpers
  include HasCallFlowLogic
  include PumiHelpers

  AUDIO_CONTENT_TYPES = %w[audio/mpeg audio/mp3 audio/wav].freeze

  belongs_to :account

  has_many :callout_participations, dependent: :restrict_with_error

  has_many :batch_operations,
           class_name: "BatchOperation::Base",
           dependent: :restrict_with_error

  has_many :callout_populations,
           class_name: "BatchOperation::CalloutPopulation"
  has_one :callout_population, class_name: "BatchOperation::CalloutPopulation", autosave: true

  has_many :phone_calls,
           through: :callout_participations

  has_many :remote_phone_call_events,
           through: :phone_calls

  has_many :contacts,
           through: :callout_participations

  has_one_attached :voice

  alias_attribute :calls, :phone_calls
  attr_accessor :created_by

  validates :status, presence: true

  validates :voice, file: {
    presence: true, type: AUDIO_CONTENT_TYPES,
    size: 10.megabytes
  }

  validates :commune_ids,
            array_inclusion: { in: :permitted_commune_ids }, if: :created_by

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

  private

  def permitted_commune_ids
    ids = []
    created_by.province_ids.each do |id|
      ids += Pumi::Commune.where(province_id: id).map(&:id)
    end
    ids
  end
end
