class User < ApplicationRecord
  include MetadataHelpers

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :registerable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :async

  belongs_to :account

  bitmask :roles, :as => [:member, :admin], null: false

  validates :roles, presence: true
end
