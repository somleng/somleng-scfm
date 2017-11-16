module MsisdnHelpers
  extend ActiveSupport::Concern

  included do
    delegate :normalize_number, :to => :class

    validates :msisdn,
              :presence => true,
              :phony_plausible => true

    before_validation :normalize_msisdn
  end

  class_methods do
    def where_msisdn(value)
      where(:msisdn => normalize_number(value))
    end

    def normalize_number(value)
      PhonyRails.normalize_number(value)
    end
  end

  private

  def normalize_msisdn
    self.msisdn = normalize_number(msisdn)
  end
end
