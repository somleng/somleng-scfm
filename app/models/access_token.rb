# == Schema Information
#
# Table name: oauth_access_tokens
#
#  id                     :integer          not null, primary key
#  resource_owner_id      :integer          not null
#  created_by_id          :integer          not null
#  metadata               :jsonb            not null
#  application_id         :integer
#  token                  :string           not null
#  refresh_token          :string
#  expires_in             :integer
#  revoked_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  scopes                 :string
#  previous_refresh_token :string           default(""), not null
#

class AccessToken < Doorkeeper::AccessToken
  include DatabaseAdapterHelpers
  include MetadataHelpers

  belongs_to :resource_owner, :class_name => "Account"
  belongs_to :created_by,     :class_name => "Account"

  before_destroy    :validate_destroy

  attr_accessor :destroyer

  def as_json(options = nil)
    serializable_hash(options)
  end

  private

  def serializable_hash(options = nil)
    options ||= {}
    super(
      {
        :only    => json_attributes.keys,
        :methods => json_methods.keys
      }.merge(options)
    )
  end

  def json_attributes
    {}
  end

  def json_methods
    {
      :id => nil,
      :token => nil,
      :created_at => nil,
      :updated_at => nil,
      :metadata => nil
    }
  end

  def validate_destroy
    return true if !destroyer || destroyer.super_admin? || destroyer == created_by
    errors.add(:base, :restrict_destroy_status)
    throw(:abort)
  end
end
