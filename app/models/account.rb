class Account < ApplicationRecord
  DEFAULT_PERMISSIONS_BITMASK = 0

  bitmask :permissions,
          :as => [
            :super_admin,
          ],
          :null => false

  include MetadataHelpers
  has_many :users, :dependent => :restrict_with_error

  has_one :access_token,
          :class_name => "Doorkeeper::AccessToken",
          :foreign_key => :resource_owner_id,
          :dependent => :restrict_with_error

  def super_admin?
    permissions?(:super_admin)
  end

  private

  def set_default_permissions_bitmask
    self.permissions_bitmask = DEFAULT_PERMISSIONS_BITMASK if permissions.empty?
  end
end
