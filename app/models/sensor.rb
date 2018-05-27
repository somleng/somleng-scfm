class Sensor < ApplicationRecord
  include PumiHelpers

  belongs_to :account
  has_many   :sensor_rules

  validates :account, presence: true
  validates :external_id, presence: true, uniqueness: { scope: :account_id }
end
