class Sensor < ApplicationRecord
  include PumiHelpers
  include MetadataHelpers

  REJECT_METADATA_FIELDS = [
    "commune_ids"
  ].freeze

  belongs_to :account

  has_many   :sensor_rules,
             dependent: :restrict_with_error

  has_many   :sensor_events,
             dependent: :restrict_with_error

  validates :account, presence: true
  validates :external_id, presence: true, uniqueness: { scope: :account_id }

  def metadata_fields
    @metadata_fields ||= super.reject { |field| REJECT_METADATA_FIELDS.include?(field.key) }
  end
end
