class AccessToken < Doorkeeper::AccessToken
  include DatabaseAdapterHelpers
  include MetadataHelpers

  belongs_to :resource_owner, :class_name => "Account"
  belongs_to :created_by,     :class_name => "Account"

  before_destroy    :validate_destroy

  attr_accessor :destroyer

  private

  def validate_destroy
    return true if !destroyer || destroyer == created_by
    errors.add(:base, :restrict_destroy_status)
    throw(:abort)
  end
end
