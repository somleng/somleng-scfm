class User < ApplicationRecord
  include MetadataHelpers
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :registerable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :async

  belongs_to :account

  validates_inclusion_of :locale, in: %w[en km]

  def locale_en?
    locale == "en"
  end
end
