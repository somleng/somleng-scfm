class User < ApplicationRecord
  include MetadataHelpers
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :registerable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :async

  AVAILABLE_LOCALES = %w[en km].freeze

  belongs_to :account

  validates_inclusion_of :locale, in: AVAILABLE_LOCALES
end
