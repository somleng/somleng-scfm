class CalloutParticipation < ApplicationRecord
  include MsisdnHelpers
  include MetadataHelpers
  include HasCallFlowLogic

  DEFAULT_RETRY_STATUSES = [
    "failed"
  ]

  belongs_to :callout
  belongs_to :contact
  belongs_to :callout_population,
             :optional => true,
             :class_name => "BatchOperation::CalloutPopulation"

  has_many :phone_calls

  validates :contact_id,
            :uniqueness => {:scope => :callout_id}

  validates :msisdn,
            :uniqueness => {:scope => :callout_id}

  delegate :call_flow_logic, :to => :callout, :prefix => true, :allow_nil => true
  delegate :msisdn, :to => :contact, :prefix => true, :allow_nil => true

  before_validation :set_msisdn_from_contact,
                    :on => :create

  def call_flow_logic
    super || callout_call_flow_logic
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

  def self.no_phone_calls
    left_outer_joins(:phone_calls).where(:phone_calls => {:id => nil})
  end

  def self.has_phone_calls
    joins(:phone_calls)
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

  private

  def set_msisdn_from_contact
    self.msisdn ||= contact_msisdn
  end
end
