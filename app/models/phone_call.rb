class PhoneCall < ApplicationRecord
  TWILIO_CALL_STATUSES = {
    queued: "queued",
    ringing: "ringing",
    in_progress: "in-progress",
    canceled: "canceled",
    completed: "completed",
    busy: "busy",
    failed: "failed",
    not_answered: "no-answer"
  }.freeze

  IN_PROGRESS_STATUSES = %i[remotely_queued in_progress].freeze

  # https://www.twilio.com/docs/api/voice/call#resource-properties
  TWILIO_DIRECTIONS = {
    inbound: "inbound"
  }.freeze

  belongs_to :callout_participation, optional: true, counter_cache: true
  belongs_to :contact, validate: true
  belongs_to :account
  belongs_to :callout, optional: true
  has_many   :remote_phone_call_events, dependent: :restrict_with_error

  include MetadataHelpers
  include MsisdnHelpers
  include HasCallFlowLogic

  delegate :call_flow_logic, to: :callout_participation, prefix: true, allow_nil: true
  delegate :call_flow_logic, to: :contact, prefix: true, allow_nil: true

  delegate :contact,
           :msisdn,
           to: :callout_participation,
           prefix: true,
           allow_nil: true

  delegate :platform_provider,
           to: :account

  before_validation :set_defaults, on: :create
  before_destroy    :validate_destroy

  accepts_nested_key_value_fields_for :remote_response
  accepts_nested_key_value_fields_for :remote_queue_response

  include AASM

  aasm column: :status, whiny_transitions: false do
    state :created, initial: true
    state :queued
    state :remotely_queued
    state :errored
    state :failed
    state :in_progress
    state :busy
    state :not_answered
    state :canceled
    state :completed
    state :expired

    event :queue do
      transitions(
        from: :created,
        to: :queued
      )
    end

    event :queue_remote, after_commit: :touch_remotely_queued_at do
      transitions(
        from: :queued,
        to: :remotely_queued,
        if: :remote_call_id?
      )

      transitions(
        from: :queued,
        to: :errored
      )
    end

    event :complete do
      transitions from: %i[created remotely_queued expired],
                  to: :in_progress,
                  if: :remote_status_in_progress?

      transitions from: %i[created remotely_queued in_progress expired],
                  to: :busy,
                  if: :remote_status_busy?

      transitions from: %i[created remotely_queued in_progress expired],
                  to: :failed,
                  if: :remote_status_failed?

      transitions from: %i[created remotely_queued in_progress expired],
                  to: :not_answered,
                  if: :remote_status_not_answered?

      transitions from: %i[created remotely_queued in_progress expired],
                  to: :canceled,
                  if: :remote_status_canceled?

      transitions from: %i[created remotely_queued in_progress],
                  to: :expired,
                  if: :remote_call_expired?

      transitions from: %i[created remotely_queued in_progress expired],
                  to: :completed,
                  after: :mark_callout_participation_answered!,
                  if: :remote_status_completed?
    end
  end

  def self.to_fetch_remote_status
    where(status: IN_PROGRESS_STATUSES, remotely_queued_at: ..10.minutes.ago)
      .merge(
        where(remote_status_fetch_queued_at: nil).or(where(remote_status_fetch_queued_at: ..15.minutes.ago))
      )
  end

  def inbound?
    remote_direction == TWILIO_DIRECTIONS[:inbound]
  end

  def direction
    inbound? ? :inbound : :outbound
  end

  def set_call_flow_logic
    return if call_flow_logic.present?

    self.call_flow_logic = callout_participation_call_flow_logic || contact_call_flow_logic
  end

  def remote_call_expired?
    remote_status == "queued" && remotely_queued_at < 1.hour.ago
  end

  private

  def touch_remotely_queued_at
    touch(:remotely_queued_at)
  end

  def remote_status_in_progress?
    [
      TWILIO_CALL_STATUSES.fetch(:in_progress),
      TWILIO_CALL_STATUSES.fetch(:ringing)
    ].include?(remote_status)
  end

  %i[busy failed not_answered canceled completed].each do |status|
    define_method("remote_status_#{status}?") do
      remote_status == TWILIO_CALL_STATUSES.fetch(status)
    end
  end

  def set_defaults
    self.msisdn  ||= callout_participation_msisdn
    self.contact ||= callout_participation_contact
    self.account ||= contact&.account
    set_call_flow_logic
  end

  def validate_destroy
    return true if created?

    errors.add(:base, :restrict_destroy_status, status: status)
    throw(:abort)
  end

  def mark_callout_participation_answered!
    return true if callout_participation.blank?

    callout_participation.update!(answered: true)
  end
end
