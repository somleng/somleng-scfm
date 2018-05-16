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

  delegate :province, :district, to: :commune, allow_nil: true
  delegate :name_en, to: :commune, prefix: true, allow_nil: true
  delegate :id, :name_en, to: :province, prefix: true, allow_nil: true
  delegate :id, :name_en, to: :district, prefix: true, allow_nil: true

  def commune
    @commune ||= Pumi::Commune.find_by_id(commune_id)
  end
end
