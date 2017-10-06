module MsisdnHelpers
  extend ActiveSupport::Concern

  included do
    validates :msisdn,
              :presence => true,
              :phony_plausible => true

    before_validation :normalize_msisdn
  end

  private

  def normalize_msisdn
    self.msisdn = PhonyRails.normalize_number(msisdn)
  end
end
