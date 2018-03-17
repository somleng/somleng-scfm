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
