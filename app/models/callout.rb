class Callout < ApplicationRecord
  include HasMetadata

  has_many :phone_numbers
  has_many :phone_calls, :through => :phone_numbers
end
