class Contact < ApplicationRecord
  include MsisdnHelpers
  include MetadataHelpers

  has_many :phone_numbers
  has_many :callouts, :through => :phone_numbers

  validates :msisdn,
            :uniqueness => true
end
