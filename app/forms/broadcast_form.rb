class BroadcastForm < ApplicationForm
  attribute :account
  attribute :channel
  attribute :audio_file
  attribute :message
  attribute :created_by
  attribute :started_by
  attribute :stopped_by
  attribute :updated_by
  attribute :name
  attribute :beneficiary_groups, FilledArrayType.new
  attribute :beneficiary_filter,
            FilterFormType.new(
              form:  BeneficiaryFilterForm,
              filter_data: BeneficiaryFilterData,
              field_definitions: FieldDefinitions::BeneficiaryFields
            ),
            default: -> { BeneficiaryFilterForm.new }

  attribute :geocode_target_areas, ActiveRecord::Type::Json.new, default: []
  attribute :geocode_target_area_validator, default: -> { GeocodeTargetAreaValidator.new }
  attribute :object, default: -> { Broadcast.new }

  enumerize :channel, in: Broadcast.channel.values, default: ->(form) { form.supported_channels.first }

  delegate :id, :new_record?, :persisted?, to: :object
  delegate :supported_channels, to: :account

  validates :channel, presence: true
  validates :audio_file, presence: true, if: -> { new_record? && channel_capabilities.audio? }
  validates :message, presence: true, if: -> { channel_capabilities.text? }
  validates :channel, presence: true, inclusion: { in: ->(form) { form.supported_channels } }, if: :new_record?
  validates :beneficiary_groups, length: { maximum: Broadcast::MAX_BENEFICIARY_GROUPS, allow_blank: true }

  validate :validate_audio_file
  validate :validate_status
  validate :validate_geocode_target_areas

  def self.model_name
    Broadcast.model_name
  end

  def self.initialize_with(broadcast)
    new(
      object: broadcast,
      account: broadcast.account,
      name: broadcast.name,
      message: broadcast.message,
      channel: broadcast.channel,
      audio_file: broadcast.audio_file.blob,
      beneficiary_groups: broadcast.beneficiary_group_ids,
      beneficiary_filter: BeneficiaryFilterData.new(data: broadcast.beneficiary_filter),
      geocode_target_areas: broadcast.target_areas.geocode
    )
  end

  def save
    return false if invalid?

    attributes = {}
    attributes[:account] = account
    attributes[:name] = name.presence
    attributes[:message] = message if channel_capabilities.text?
    attributes[:audio_file] = audio_file if channel_capabilities.audio?
    attributes[:beneficiary_group_ids] = account.beneficiary_groups.where(id: beneficiary_groups).pluck(:id)
    attributes[:target_areas] = build_target_areas unless geocode_target_areas.blank?
    attributes[:beneficiary_filter] = FilterFormType.new(
      form: BeneficiaryFilterForm,
      filter_data: BeneficiaryFilterData,
      field_definitions: FieldDefinitions::BeneficiaryFields
    ).serialize(beneficiary_filter)

    if new_record?
      self.object = CreateBroadcast.call(
        channel:,
        created_by:,
        created_via: :dashboard,
        **attributes
      )
    else
      UpdateBroadcast.call(object, updated_by:, **attributes)
    end

    true
  end

  def channel_options_for_select
    BroadcastForm.channel.values.select { supported_channels.include?(it) }.map { [ it.text, it ] }
  end

  def beneficiary_filter_fields
    FieldDefinitions::BeneficiaryFields.select do |field|
      next false if field.name == :status
      next true if account.dashboard_broadcast_beneficiary_filter_whitelist.blank?

      account.dashboard_broadcast_beneficiary_filter_whitelist.include?(field.name.to_s)
    end
  end

  private

  def channel_capabilities
    BroadcastChannelCapabilities.new(channel)
  end

  def state_machine
    @state_machine ||= BroadcastStateMachine.new(object.status)
  end

  def build_target_areas
    target_areas = object.target_areas.as_json
    target_areas["geocode"] = geocode_target_areas
    target_areas
  end

  def validate_audio_file
    return if audio_file.blank?

    object.audio_file = audio_file

    if object.invalid?(:audio_file)
      object.errors[:audio_file].each do |message|
        errors.add(:audio_file, message)
      end
    end
  end

  def validate_status
    errors.add(:base, :invalid) unless state_machine.updatable?
  end

  def validate_geocode_target_areas
    geocode_target_areas.each do |area|
      next if geocode_target_area_validator.valid?(area)

      return errors.add(:geocode_target_areas, :invalid)
    end
  end
end
