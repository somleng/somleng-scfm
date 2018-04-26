class User < ApplicationRecord
  include MetadataHelpers

  store_accessor :metadata, :location_ids

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :registerable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :async

  belongs_to :account

  bitmask :roles, :as => [:member, :admin], null: false

  validates :roles, presence: true
  validates :location_ids, array: true, if: 'location_ids.present?'

  def is_admin?
    roles?(:admin)
  end
end
