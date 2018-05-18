class Sensor < ApplicationRecord
  store_accessor :metadata, :province_id

  belongs_to :account

  validates :account, :province_id, presence: true
end
