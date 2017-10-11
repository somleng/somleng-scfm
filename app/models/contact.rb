class Contact < ApplicationRecord
  include MsisdnHelpers
  include MetadataHelpers

  has_many :callout_participations
  has_many :callouts, :through => :callout_participations

  validates :msisdn,
            :uniqueness => true
end
