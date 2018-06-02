class Sensor < ApplicationRecord
  include PumiHelpers
  include MetadataHelpers

  belongs_to :account
  has_many   :sensor_rules,
             dependent: :restrict_with_error

  validates :account, presence: true
  validates :external_id, presence: true, uniqueness: { scope: :account_id }
end
