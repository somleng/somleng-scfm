class Contact < ApplicationRecord
  include MsisdnHelpers
  include MetadataHelpers

  has_many :callout_participations
  has_many :callouts, :through => :callout_participations
  has_many :phone_calls

  validates :msisdn,
            :uniqueness => true
end
