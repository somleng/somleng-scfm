class Contact < ApplicationRecord
  include MsisdnHelpers
  include MetadataHelpers

  has_many :callout_participants
  has_many :callouts, :through => :callout_participants

  validates :msisdn,
            :uniqueness => true
end
