class PhoneNumber < ApplicationRecord
  belongs_to :callout
  has_many :phone_calls

  validates :msisdn,
            :presence => true,
            :uniqueness => {:scope => :callout_id},
            :phony_plausible => true

  before_validation :normalize_msisdn

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

  def self.last_phone_call_attempt(status)
    # Adapted from:
    # https://stackoverflow.com/questions/2111384/sql-join-selecting-the-last-records-in-a-one-to-many-relationship

    # Explanation:
    # given a row phone_call, there should be no row future_phone_calls with
    # the same phone number and a later timestamp.
    # When we find that to be true,
    # then phone_call is the most recent phone_call for that phone_number.

    joins(:phone_calls).joins(
      "LEFT OUTER JOIN \"phone_calls\" \"future_phone_calls\" ON (\"future_phone_calls\".\"phone_number_id\" = \"phone_numbers\".\"id\" AND \"phone_calls\".\"created_at\" < \"future_phone_calls\".\"created_at\")"
    ).where(
      :future_phone_calls => {:id => nil}
    ).where(
      :phone_calls => {
        :status => [status]
      }
    )
  end

  private

  def normalize_msisdn
    self.msisdn = PhonyRails.normalize_number(msisdn)
  end
end
