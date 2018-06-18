class User < ApplicationRecord
  AVAILABLE_LOCALES = %w[en km].freeze

  include MetadataHelpers

  store_accessor :metadata, :province_ids

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :registerable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :async

  belongs_to :account
  validates_inclusion_of :locale, in: AVAILABLE_LOCALES

  bitmask :roles, as: %i[member admin], null: false

  before_validation :remove_empty_province_ids

  validates :roles, presence: true

  def admin?
    roles?(:admin)
  end

  private

  def remove_empty_province_ids
    self.province_ids = Array(province_ids).reject(&:blank?).presence
  end
end
