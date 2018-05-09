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

  def commune
    @commune ||= Pumi::Commune.find_by_id(commune_id)
  end

  def province_id
    @province_id ||= commune&.province&.id
  end

  def district_id
    @district_id ||= commune&.district&.id
  end
end
