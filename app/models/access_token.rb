class AccessToken < Doorkeeper::AccessToken
  DEFAULT_PERMISSIONS_BITMASK = 0
  # do not change the order of this array
  # add new permissions to the end of the array

  PERMISSIONS = %i[
    access_tokens_read
    access_tokens_write
    accounts_read
    accounts_write
    batch_operations_read
    batch_operations_write
    callout_participations_read
    callout_participations_write
    callouts_read
    callouts_write
    contacts_read
    contacts_write
    phone_calls_read
    phone_calls_write
    remote_phone_call_events_read
    remote_phone_call_events_write
    users_read
    users_write
    recordings_read
  ].freeze

  include TimestampQueryHelpers
  include MetadataHelpers

  belongs_to :resource_owner, class_name: "Account"
  belongs_to :created_by,     class_name: "Account"

  before_destroy :validate_destroy

  bitmask :permissions,
          as: PERMISSIONS,
          null: false

  attr_accessor :destroyer

  def as_json(options = nil)
    serializable_hash(options)
  end

  def permissions_text
    permissions.sort.map do |permission|
      I18n.translate(
        :"simple_form.options.access_token.permissions.#{permission}",
        default: permission.to_s.humanize
      )
    end.join(", ")
  end

  private

  def serializable_hash(options = nil)
    options ||= {}
    super(
      {
        only: json_attributes.keys,
        methods: json_methods.keys
      }.merge(options)
    )
  end

  def json_attributes
    {}
  end

  def json_methods
    {
      id: nil,
      token: nil,
      created_at: nil,
      updated_at: nil,
      metadata: nil,
      permissions: nil
    }
  end

  def validate_destroy
    return true if !destroyer || destroyer.super_admin? || destroyer == created_by

    errors.add(:base, :restrict_destroy_status)
    throw(:abort)
  end
end
