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

  belongs_to :phone_number

  serialize :remote_response, JSON

  validates :remote_call_id, :uniqueness => {:case_sensitive => false, :allow_nil => true}
  validates :status, :presence => true

  include AASM

  aasm :column => :status, :whiny_transitions => false do
    state :created, :initial => true
    state :scheduling
    state :queued
    state :errored
    state :failed
    state :in_progress
    state :busy
    state :not_answered
    state :canceled
    state :completed

    event :schedule do
      transitions(
        :from => :created,
        :to => :scheduling
      )
    end

    event :queue do
      transitions(
        :from => :scheduling,
        :to => :queued,
        :guard => :has_remote_call_id?
      )

      transitions(
        :from => :scheduling,
        :to => :errored
      )
    end

    event :complete do
      transitions :from => :queued,
                  :to => :in_progress,
                  :if => :remote_status_in_progress?

      transitions :from => [:queued, :in_progress],
                  :to => :busy,
                  :if => :remote_status_busy?

      transitions :from => [:queued, :in_progress],
                  :to => :failed,
                  :if => :remote_status_failed?

      transitions :from => [:queued, :in_progress],
                  :to => :not_answered,
                  :if => :remote_status_not_answered?

      transitions :from => [:queued, :in_progress],
                  :to => :canceled,
                  :if => :remote_status_canceled?

      transitions :from => [:queued, :in_progress],
                  :to => :completed,
                  :if => :remote_status_completed?
    end
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

  def self.time_considered_recently_created_seconds
    (ENV["PHONE_CALL_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS"] || DEFAULT_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS).to_i
  end

  private

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
end
