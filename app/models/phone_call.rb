class PhoneCall < ApplicationRecord
  DEFAULT_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS = 60

  TWILIO_CALL_STATUSES = {
    :queued => "queued",
    :ringing => "ringing",
    :in_progress => "in-progress",
    :canceled => "canceled",
    :completed => "completed",
    :busy => "busy",
    :failed => "failed",
    :not_answered => "no-answer"
  }

  # https://www.twilio.com/docs/api/voice/call#resource-properties
  TWILIO_DIRECTIONS = {
    :inbound => "inbound"
  }

  belongs_to :callout_participation, :optional => true
  belongs_to :contact, :validate => true
  has_many   :remote_phone_call_events, :dependent => :restrict_with_error

  include MetadataHelpers
  include Wisper::Publisher
  include MsisdnHelpers

  conditionally_serialize(:remote_response, JSON)
  conditionally_serialize(:remote_request_params, JSON)
  conditionally_serialize(:remote_queue_response, JSON)

  validates :remote_call_id, :uniqueness => {:case_sensitive => false, :allow_nil => true}
  validates :status, :presence => true
  validates :callout_participation, :presence => true, :unless => :inbound?

  delegate :call_flow_logic, :to => :callout_participation, :prefix => true, :allow_nil => true

  delegate :contact,
           :msisdn,
           :to => :callout_participation,
           :prefix => true,
           :allow_nil => true

  before_validation :set_defaults, :on => :create
  before_destroy    :validate_destroy

  include AASM

  aasm :column => :status, :whiny_transitions => false do
    state :created, :initial => true
    state :queued
    state :remotely_queued
    state :errored
    state :fetching_status
    state :failed
    state :in_progress
    state :busy
    state :not_answered
    state :canceled
    state :completed

    event :queue, :after_commit => :publish_queued do
      transitions(
        :from => :created,
        :to => :queued
      )
    end

    event :queue_remote, :after_commit => :touch_remotely_queued_at do
      transitions(
        :from => :queued,
        :to => :remotely_queued,
        :guard => :has_remote_call_id?
      )

      transitions(
        :from => :queued,
        :to => :errored
      )
    end

    event :fetch_status do
      transitions(
        :from => :queued,
        :to => :fetching_status
      )
    end

    event :finish_fetching_status do
      transitions(
        :from => :fetching_status,
        :to => :queued
      )
    end

    event :complete do
      transitions :from => :fetching_status,
                  :to => :in_progress,
                  :if => :remote_status_in_progress?

      transitions :from => :fetching_status,
                  :to => :busy,
                  :if => :remote_status_busy?

      transitions :from => :fetching_status,
                  :to => :failed,
                  :if => :remote_status_failed?

      transitions :from => :fetching_status,
                  :to => :not_answered,
                  :if => :remote_status_not_answered?

      transitions :from => :fetching_status,
                  :to => :canceled,
                  :if => :remote_status_canceled?

      transitions :from => :fetching_status,
                  :to => :completed,
                  :if => :remote_status_completed?
    end
  end

  def self.remote_response_has_values(hash)
    json_has_values(hash, :remote_response)
  end

  def self.with_remote_call_id
    where.not(:remote_call_id => nil)
  end

  def self.not_recently_created
    where(arel_table[:created_at].lt(time_considered_recently_created_seconds.seconds.ago))
  end

  def self.waiting_for_completion
    queued.or(in_progress)
  end

  def self.from_running_callout
    joins(:callout_participation => :callout).merge(Callout.running)
  end

  def self.in_last_hours(hours, timestamp_column = :created_at)
    where(arel_table[timestamp_column].gt(hours.hours.ago))
  end

  def self.time_considered_recently_created_seconds
    (ENV["PHONE_CALL_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS"] || DEFAULT_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS).to_i
  end

  def call_flow_logic
    super || callout_participation_call_flow_logic
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

  [:busy, :failed, :not_answered, :canceled, :completed].each do |status|
    define_method("remote_status_#{status}?") do
      remote_status == TWILIO_CALL_STATUSES.fetch(status)
    end
  end

  def has_remote_call_id?
    remote_call_id?
  end

  def inbound?
    remote_direction == TWILIO_DIRECTIONS[:inbound]
  end

  def set_defaults
    self.contact ||= callout_participation_contact
    self.msisdn  ||= callout_participation_msisdn
  end

  def validate_destroy
    return true if created?
    errors.add(:base, :restrict_destroy_status, :status => status)
    throw(:abort)
  end

  def publish_queued
    broadcast(:phone_call_queued, self)
  end
end
