class Sensor < ApplicationRecord
  store_accessor :metadata, :province_id

  belongs_to :account
  has_many   :sensor_rules

  validates :account, :province_id, presence: true
  validates_associated :sensor_rules

  accepts_nested_attributes_for :sensor_rules, allow_destroy: true
end
