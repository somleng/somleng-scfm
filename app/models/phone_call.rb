class PhoneCall < ApplicationRecord
  DEFAULT_TIME_CONSIDERED_RECENT_SECONDS = 60

  belongs_to :phone_number

  serialize :remote_response, JSON

  validates :remote_call_id, :uniqueness => {:case_sensitive => false, :allow_nil => true}
  validates :status, :presence => true

  include AASM

  aasm :column => :status do
    state :new, :initial => true
    state :queued

    event :queue do
      transitions :from => :new,
                  :to => :queued
    end
  end

  def self.not_recent
    where(arel_table[:created_at].lt(time_considered_recent_seconds.seconds.ago))
  end

  def self.time_considered_recent_seconds
    ENV["SOMLENG_SIMPLE_CFM_TIME_CONSIDERED_RECENT_SECONDS"] || DEFAULT_TIME_CONSIDERED_RECENT_SECONDS
  end
end
