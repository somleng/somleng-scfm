class PhoneCall < ApplicationRecord
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

  belongs_to :create_batch_operation,
             :class_name => "BatchOperation::PhoneCallCreate",
             :optional => true

  belongs_to :queue_batch_operation,
             :class_name => "BatchOperation::PhoneCallQueue",
             :optional => true

  belongs_to :queue_remote_fetch_batch_operation,
             :class_name => "BatchOperation::PhoneCallQueueRemoteFetch",
             :optional => true

  belongs_to :callout_participation,
             :optional => true

  belongs_to :contact, :validate => true
  has_many   :remote_phone_call_events, :dependent => :restrict_with_error

  include MetadataHelpers
  include Wisper::Publisher
  include MsisdnHelpers
  include HasCallFlowLogic

  conditionally_serialize(:remote_response, JSON)
  conditionally_serialize(:remote_request_params, JSON)
  conditionally_serialize(:remote_queue_response, JSON)

  validates :remote_call_id, :uniqueness => {:case_sensitive => false, :allow_nil => true}
  validates :status, :presence => true
  validates :callout_participation, :presence => true, :unless => :inbound?
  validates :remote_request_params,
            :presence => true,
            :twilio_request_params => true,
            :unless => :inbound?

  delegate :call_flow_logic, :to => :callout_participation, :prefix => true, :allow_nil => true

  delegate :contact,
           :msisdn,
           :to => :callout_participation,
           :prefix => true,
           :allow_nil => true

  before_validation :set_defaults, :on => :create
  before_destroy    :validate_destroy

  attr_accessor :new_remote_status

  include AASM

  aasm :column => :status, :whiny_transitions => false do
    state :created, :initial => true
    state :queued
    state :remotely_queued
    state :errored
    state :remote_fetch_queued
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
        :if => :has_remote_call_id?
      )

      transitions(
        :from => :queued,
        :to => :errored
      )
    end

    event :queue_remote_fetch, :after_commit => :publish_remote_fetch_queued do
      transitions(
        :from => :remotely_queued,
        :to => :remote_fetch_queued,
        :if => :has_remote_call_id?
      )
    end

    event :complete do
      transitions :from => [:remotely_queued, :remote_fetch_queued, :in_progress],
                  :to => :in_progress,
                  :if => :remote_status_in_progress?

      transitions :from => [:remotely_queued, :remote_fetch_queued, :in_progress],
                  :to => :busy,
                  :if => :remote_status_busy?

      transitions :from => [:remotely_queued, :remote_fetch_queued, :in_progress],
                  :to => :failed,
                  :if => :remote_status_failed?

      transitions :from => [:remotely_queued, :remote_fetch_queued, :in_progress],
                  :to => :not_answered,
                  :if => :remote_status_not_answered?

      transitions :from => [:remotely_queued, :remote_fetch_queued, :in_progress],
                  :to => :canceled,
                  :if => :remote_status_canceled?

      transitions :from => [:remotely_queued, :remote_fetch_queued, :in_progress],
                  :to => :completed,
                  :if => :remote_status_completed?

      transitions :from => :remote_fetch_queued,
                  :to =>   :remotely_queued,
                  :if =>   :was_remotely_queued_and_new_remote_status_unknown?
    end
  end

  def self.in_last_hours(hours, timestamp_column = :created_at)
    where(arel_table[timestamp_column].gt(hours.hours.ago))
  end

  def call_flow_logic
    super || callout_participation_call_flow_logic
  end

  def inbound?
    remote_direction == TWILIO_DIRECTIONS[:inbound]
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

  def set_defaults
    self.msisdn  ||= callout_participation_msisdn
    self.contact ||= callout_participation_contact || find_or_initialize_contact
  end

  def find_or_initialize_contact
    Contact.where_msisdn(msisdn).first_or_initialize
  end

  def validate_destroy
    return true if created?
    errors.add(:base, :restrict_destroy_status, :status => status)
    throw(:abort)
  end

  def publish_queued
    broadcast(:phone_call_queued, self)
  end

  def publish_remote_fetch_queued
    broadcast(:phone_call_remote_fetch_queued, self)
  end

  def was_remotely_queued_and_new_remote_status_unknown?
    remotely_queued_at? && !new_remote_status
  end
end
