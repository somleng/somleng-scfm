class CalloutParticipation < ApplicationRecord
  include MsisdnHelpers
  include MetadataHelpers

  DEFAULT_RETRY_STATUSES = [
    "failed"
  ]

  belongs_to :callout
  belongs_to :contact
  has_many :phone_calls

  validates :contact_id,
            :uniqueness => {:scope => :callout_id}

  validates :msisdn,
            :uniqueness => {:scope => :callout_id}

  def self.from_running_callout
    joins(:callout).merge(Callout.running)
  end

  def self.no_phone_calls_or_last_attempt(status)
    where(
      :id => no_phone_calls
    ).or(
      where(
        :id => last_phone_call_attempt(status)
      )
    )
  end

  def self.completed
    last_phone_call_attempt(PhoneCall.aasm.states.map(&:to_s) - retry_statuses)
  end

  def self.remaining
    no_phone_calls_or_last_attempt(retry_statuses)
  end

  def self.no_phone_calls
    left_outer_joins(:phone_calls).where(:phone_calls => {:id => nil})
  end

  def self.last_phone_call_attempt(status)
    # Adapted from:
    # https://stackoverflow.com/questions/2111384/sql-join-selecting-the-last-records-in-a-one-to-many-relationship

    # Explanation:
    # given a row phone_call, there should be no row future_phone_calls with
    # the same callout_participation and a later timestamp.
    # When we find that to be true,
    # then phone_call is the most recent phone_call for that callout_participation.

    joins(:phone_calls).joins(
      "LEFT OUTER JOIN \"phone_calls\" \"future_phone_calls\" ON (\"future_phone_calls\".\"callout_participation_id\" = \"callout_participations\".\"id\" AND \"phone_calls\".\"created_at\" < \"future_phone_calls\".\"created_at\")"
    ).where(
      :future_phone_calls => {:id => nil}
    ).where(
      :phone_calls => {
        :status => [status]
      }
    )
  end

  def self.last_phone_call_attempt_not(status)
    status_scope = PhoneCall.where.not(:status => [status])
  end

  def self.default_retry_statuses
    DEFAULT_RETRY_STATUSES
  end

  def self.retry_statuses
    ENV["CALLOUT_PARTICIPATION_RETRY_STATUSES"].present? ? ENV["CALLOUT_PARTICIPATION_RETRY_STATUSES"].to_s.split(",") : default_retry_statuses
  end
end
