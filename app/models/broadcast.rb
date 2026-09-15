class Broadcast < ApplicationRecord
  AUDIO_CONTENT_TYPES = %w[audio/mpeg audio/mp3 audio/wav audio/x-wav].freeze
  MAX_BENEFICIARY_GROUPS = 10

  class StateMachine < ::StateMachine::ActiveRecord
    state :pending, initial: true, transitions_to: :queued
    state :queued, transitions_to: [ :running, :errored ]
    state :errored, transitions_to: :queued
    state :running, transitions_to: [ :stopped, :completed ]
    state :stopped, transitions_to: [ :running, :completed ]
    state :completed
  end

  attribute :target_areas, TargetAreaDataType.new

  enumerize :channel, in: [ :voice_call, :text_message, :audio ]
  enumerize :status, in: StateMachine.state_definitions.map(&:name)
  enumerize :created_via, in: [ :api, :dashboard ]

  belongs_to :account
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :started_by, class_name: "User", optional: true
  belongs_to :stopped_by, class_name: "User", optional: true
  belongs_to :updated_by, class_name: "User", optional: true

  has_many :geocode_target_areas
  has_many :notifications
  has_many :beneficiaries, through: :notifications
  has_many :delivery_attempts
  has_many :broadcast_beneficiary_groups
  has_many :beneficiary_groups, through: :broadcast_beneficiary_groups
  has_many :group_beneficiaries, -> { distinct }, through: :beneficiary_groups, source: :members, class_name: "Beneficiary"

  has_one_attached :audio_file

  validates :audio_file,
            file_size: {
              less_than_or_equal_to: 10.megabytes
            },
            file_content_type: {
              allow: AUDIO_CONTENT_TYPES
            },
            if: ->(broadcast) { broadcast.audio_file.attached? }

  validates :channel, presence: true
  validates :beneficiary_groups, length: { maximum: MAX_BENEFICIARY_GROUPS, allow_blank: true }

  delegate :running?, :stopped?, :completed?, :pending?, :queued?, :errored?, :may_transition_to?, :transition_to!, :transition_to, to: :state_machine

  before_create :set_default_status

  def self.geocode_target_areas_equal(...)
    joins(:geocode_target_areas)
    .merge(GeocodeTargetArea.where(...))
    .where.not(id: GeocodeTargetArea.outside(...).select(:broadcast_id)).distinct
  end

  def self.geocode_target_areas_contain(...)
    joins(:geocode_target_areas).merge(GeocodeTargetArea.where(...))
  end

  def mark_as_errored!(error_code)
    transaction do
      state_machine.transition_to!(:errored)
      update!(error_code:)
    end
  end

  def channel_capabilities
    @channel_capabilities ||= Array(channel).map { BroadcastChannelCapabilities.new(channel) }
  end

  private

  def state_machine
    StateMachine.new(self)
  end

  def set_default_status
    self.status ||= state_machine.current_state.name
  end
end
