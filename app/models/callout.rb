class Callout < ApplicationRecord
  has_many :phone_numbers
  has_many :phone_calls, :through => :phone_numbers
end
