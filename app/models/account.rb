class Account < ApplicationRecord
  DEFAULT_PERMISSIONS_BITMASK = 0
  TWILIO_ACCOUNT_SID_PREFIX = "AC"

  include MetadataHelpers

  conditionally_serialize(:settings, JSON)

  store_accessor :settings,
                 :twilio_auth_token,
                 :somleng_auth_token

  bitmask :permissions,
          :as => [
            :super_admin,
          ],
          :null => false

  has_one :access_token,
          :class_name => "Doorkeeper::AccessToken",
          :foreign_key => :resource_owner_id,
          :dependent => :restrict_with_error

  has_many :users,
           :dependent => :restrict_with_error

  has_many :contacts,
           :dependent => :restrict_with_error

  has_many :callouts,
           :dependent => :restrict_with_error

  has_many :batch_operations,
           :class_name => "BatchOperation::Base",
           :dependent => :restrict_with_error

  has_many :callout_participations,
           :through => :callouts

  has_many :phone_calls,
           :through => :callout_participations

  has_many :remote_phone_call_events,
           :through => :phone_calls

  delegate :twilio_account_sid?, :to => :class

  def super_admin?
    permissions?(:super_admin)
  end

  def self.by_platform_account_sid(account_sid)
    where(twilio_account_sid?(account_sid) ? :twilio_account_sid : :somleng_account_sid => account_sid)
  end

  def platform_auth_token(account_sid)
    twilio_account_sid?(account_sid) ? twilio_auth_token : somleng_auth_token
  end

  def self.twilio_account_sid?(account_sid)
    account_sid.to_s.start_with?(TWILIO_ACCOUNT_SID_PREFIX)
  end

  private

  def set_default_permissions_bitmask
    self.permissions_bitmask = DEFAULT_PERMISSIONS_BITMASK if permissions.empty?
  end
end
