class PhoneNumber < ApplicationRecord
  has_many :phone_calls

  validates :msisdn,
            :presence => true,
            :uniqueness => true,
            :phony_plausible => true

  before_validation :normalize_msisdn

  def normalize_msisdn
    self.msisdn = PhonyRails.normalize_number(msisdn)
  end
end
