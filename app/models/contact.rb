class Contact < ApplicationRecord
  include MsisdnHelpers
  include MetadataHelpers

  store_accessor :metadata, :commune_id
  attr_accessor :province_id, :district_id

  belongs_to :account

  has_many :callout_participations,
           dependent: :restrict_with_error

  has_many :callouts,
           through: :callout_participations

  has_many :phone_calls,
           dependent: :restrict_with_error

  has_many :remote_phone_call_events,
           through: :phone_calls

  validates :msisdn,
            uniqueness: { scope: :account_id }

  validates :commune_id, presence: true, on: :dashboard
  validate  :validate_commune_id

  delegate :province, :district, to: :commune, allow_nil: true
  delegate :name_en, :name_km, to: :commune, prefix: true, allow_nil: true
  delegate :id, :name_en, :name_km, to: :province, prefix: true, allow_nil: true
  delegate :id, :name_en, :name_km, to: :district, prefix: true, allow_nil: true

  delegate :call_flow_logic,
           to: :account,
           allow_nil: true

  def commune
    @commune ||= Pumi::Commune.find_by_id(commune_id)
  end

  private

  def validate_commune_id
    return if commune_id.blank?
    errors.add(:commune_id, :invalid) unless Pumi::Commune.find_by_id(commune_id)
  end
end
