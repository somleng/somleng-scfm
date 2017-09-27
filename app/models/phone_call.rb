class PhoneCall < ApplicationRecord
  DEFAULT_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS = 60

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
  end

  def has_remote_call_id?
    remote_call_id?
  end

  def self.not_recently_created
    where(arel_table[:created_at].lt(time_considered_recently_created_seconds.seconds.ago))
  end

  def self.time_considered_recently_created_seconds
    (ENV["PHONE_CALL_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS"] || DEFAULT_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS).to_i
  end
end
