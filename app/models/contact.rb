class Contact < ApplicationRecord
  include MsisdnHelpers
  include MetadataHelpers

  has_many :callout_participations, :dependent => :restrict_with_error
  has_many :callouts, :through => :callout_participations
  has_many :phone_calls, :dependent => :restrict_with_error

  validates :msisdn,
            :uniqueness => true
end
